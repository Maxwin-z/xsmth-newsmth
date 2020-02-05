//
//  SMPostViewControllerV4.swift
//  newsmth
//
//  Created by WenDong on 2020/1/28.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit
import Foundation
import Combine
import WebKit
import Alamofire
import Loaf

struct SMBridgeError : Error {
    let code: Int
    let message: String
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}

let mmkvKey_forwardTarget = "forwardTarget"

class SMPostViewControllerV4 : SMViewController, WKScriptMessageHandler {

    let mmkv = MMKV.default()
    
    @objc var post:SMPost?
    var postForAction: SMPost?
    var webView:WKWebView!
    
    var cancellables: [Int: AnyCancellable] = [:]
    var promiseID:Int = 0
    var bridges:[String: ((Any) -> Future<Any, SMBridgeError>)] = [:]
    
    override func viewDidLoad() {
        self.title = "Post"

        
//        bridges = ["ajax": self._ajax]    // will cause memory leak
        
        let userContentController = WKUserContentController()
        userContentController.add(LeakAvoider(delegate:self), name: "nativeBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.view.addSubview(self.webView)
        let urlString = "http://10.0.0.11:3000/"
        let request = URLRequest(url: URL(string: urlString)!)
        self.webView.load(request)
        debugPrint("post: ", post ?? "nil");
        
        // add refresh
        let refreshControl = UIRefreshControl()
        self.webView.scrollView.addSubview(refreshControl)
    }
    
    deinit {
        self.webView.stopLoading()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeBridge")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("message: ", message.name, message.body)
        if(message.name != "nativeBridge") {
            // unexpected message
            return
        }
        if let body = message.body as? Dictionary<String, AnyObject> {
//            debugPrint(body)
            guard let methodName = body["methodName"] as? String else {
                debugPrint("invalid methodName")
                return
            }
            guard let callbackID = body["callbackID"] as? Int else {
                debugPrint("invalid callbackID")
                return
            }
            var fn:((Any) -> Future<Any, SMBridgeError>)?
            if (methodName == "setTitle")  { fn = self._setTitle}
            if (methodName == "postInfo")  { fn = self._postInfo}
            if (methodName == "reply")  { fn = self._reply}
            if (methodName == "activity")  { fn = self._activity}
            if (methodName == "ajax")  { fn = self._ajax}

            if(fn == nil) {
                sendMessageToWeb(callbackID: callbackID, code: -1, data: "", message: "不存在的Bridge方法[\(methodName)]")
                return
            }
            let parameters = body["parameters"] as Any
            let index = promiseID
            var tryToRemoveSync = false
            promiseID += 1
            cancellables[index] = fn!(parameters).sink(receiveCompletion: {[weak self] ret in
                guard let weakSelf = self else {
                    return;
                }

                switch(ret) {
                case .finished:
                    debugPrint("success")
                case let .failure(error):
                    weakSelf.sendMessageToWeb(callbackID: callbackID, code: error.code, data: [:], message: error.message)
                    debugPrint("failure", error)
                }
                if((weakSelf.cancellables.removeValue(forKey: index)) == nil) {
                    tryToRemoveSync = true
                }
                debugPrint(weakSelf.cancellables)
            }, receiveValue: {[weak self] data in
                self?.sendMessageToWeb(callbackID: callbackID, code: 0, data: data, message: "")
            })
            if (tryToRemoveSync) {
                self.cancellables.removeValue(forKey: index)
            }
        }
    }
    
    func sendMessageToWeb(callbackID: Int, code: Int, data: Any, message: String) {
        weak var wealSelf = self
        do {
//            throw SMBridgeError(code: -1, message: "debug") // test
            let rspData = try JSONSerialization.data(withJSONObject: ["code": code, "data": data, "message": message], options: .prettyPrinted)
            let rspString = String(data: rspData, encoding: .utf8) ?? "{code:1, message: 'JSON转换异常'}"
            let js = "window.$xCallback(\(callbackID), \(rspString))"
            wealSelf?.webView.evaluateJavaScript(js) { debugPrint($0 ?? "", $1 ?? "") }
//            debugPrint("js: \(js)")
        } catch {
            let js = "window.$xCallback(\(callbackID), {code: -1, message: '序列化Bridge返回值异常'})"
            wealSelf?.webView.evaluateJavaScript(js) { debugPrint($0 ?? "", $1 ?? "") }
            debugPrint(error)
        }
    }
    
    func _ajax(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future<Any, SMBridgeError> { promise in
            if let opts = parameters as? Dictionary<String, AnyObject> {
                let headers = HTTPHeaders(opts["headers"] as? [String: String] ?? [:])
                if let url = opts["url"] as? String {
                    AF.request(url, headers: headers).response { rsp in
                        if case let .failure(error) = rsp.result {
                            debugPrint(error.errorDescription ?? "")
                            promise(.failure(SMBridgeError(code: -1, message: "AFError:" + (error.errorDescription ?? "unknown error"))))
                        } else {
                            do {
                                if let data = try rsp.result.get() {
                                    let ct = rsp.response?.headers.value(for: "content-type")
                                    debugPrint("ct", ct!)
                                    var html: String = ""
                                    if ((ct?.uppercased().contains("GBK"))!) {
                                        html = SMUtils.gb2312Data2String(data);
                                    } else {
                                        html = String(data: data, encoding: .utf8)!
                                    }
                                    promise(.success(html))
                                } else {
                                    promise(.failure(SMBridgeError(code: -1, message: "请求回包为空")))
                                }
                            } catch {
                                promise(.failure(SMBridgeError(code: -1, message: "请求回包错误: " + (error.asAFError?.errorDescription ?? "unknown error"))))
                            }
                        }
                    }
                } else {
                    promise(.failure(SMBridgeError(code: -1, message: "错误的请求地址")))
                }
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的Bridge参数")))
            }
        }
    }
    
    @objc
    func reply() {
       let writer = SMWritePostViewController()
        writer.post = self.postForAction
        writer.postTitle = self.postForAction?.title
        writer.title = "回复-" + (self.postForAction?.title ?? "")
        let nvc = P2PNavigationController(rootViewController: writer)
        if (SMConfig.iPadMode()) {
            SMIPadSplitViewController.instance()?.present(nvc, animated: true, completion: nil);
        } else {
            self.present(nvc, animated: true, completion: nil)
        }
    }
    
    func _reply(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            guard let weakSelf = self else {return}
            if let _postForAction = parameters as? Dictionary<String, AnyObject> {
                weakSelf.postForAction = SMPost.init(json: _postForAction)
                if (!SMAccountManager.instance()!.isLogin) {
                    weakSelf.performSelector(afterLogin: #selector(weakSelf.reply))
                } else {
                    weakSelf.reply()
                }
                promise(.success(true))
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "无效的帖子信息")))
            }
        }
    }
    
    func _postInfo(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            promise(.success([
                              "pid": self?.post?.pid as Any,
                              "gid": self?.post?.gid as Any,
                              "board": self?.post?.board?.name as Any
            ]))
        }
    }
    
    func _activity(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            if let _postForAction = parameters as? Dictionary<String, AnyObject> {
                self?.postForAction = SMPost.init(json: _postForAction)
                guard let p = self?.postForAction else {
                    promise(.failure(SMBridgeError(code: -1, message: "page unloaded")))
                    return
                }
                let forward = SMForwardActivity()
                let urlString = "https://m.newsmth.net/article/\(p.board.name!)/single/\(p.pid)/0"
                let url = URL(string: urlString)
                let activity = UIActivityViewController(activityItems: [
                    p.content!, url!], applicationActivities: [forward])
                activity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    if !completed {
                        return
                    }
                    let at = activityType?.rawValue ?? ""
                    if (at == SMActivityForwardActivity) {
                        self?.forwardActivity()
                    }
                    debugPrint(activityType?.rawValue ?? "no activity")
                }
                self?.present(activity, animated: true, completion: nil)
            }
            promise(.success(true))
        }
    }
    
    func _setTitle(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            if let title = parameters as? String {
                self?.title = title
            }
            promise(.success(true))
        }

    }

    func _nope(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
    /// activity methods
    @objc
    func forwardActivity() {
        if (!SMAccountManager.instance()!.isLogin) {
            self.performSelector(afterLogin: #selector(self.forwardActivity))
            return
        }
        
        let alert = UIAlertController(title: "转寄", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {[weak self] textField in
            textField.placeholder = "请输入转寄地址"
            var forwardTarget = self?.mmkv.string(forKey: mmkvKey_forwardTarget) ?? ""
            if (forwardTarget == "") {
                forwardTarget = SMAccountManager.instance()?.name ?? ""
            }
            textField.text = forwardTarget
        })
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak alert, weak self]  (_) in
            guard let textField = alert?.textFields?[0],
                let userText = textField.text,
            let p = self?.postForAction,
            let weakSelf = self else { return }
            debugPrint("alert", userText)
            weakSelf.mmkv.set(userText, forKey: mmkvKey_forwardTarget)
            let url = "https://m.newsmth.net/article/\(p.board.name!)/forward/\(p.pid)"
            AF.request(url, method: .post, parameters: ["target": userText]).response { response in
                debugPrint(response)
                do {
                    if let data = try response.result.get() {
                        var html = String(data: data, encoding: .utf8)!
                        html = html.replacingOccurrences(of: "`", with: "\\`")
                        weakSelf.webView.evaluateJavaScript("window.$x_parseForward(`\(html)`)") { (result, error) in
                            if let msg = result as? String{
                                if (msg == "1") {
                                    Loaf("转寄成功", state: .success, sender: weakSelf).show()
                                } else {
                                    Loaf(msg, state: .error, sender: weakSelf).show()
                                }
                            } else {
                                Loaf(error?.localizedDescription ?? "未知错误", state: .error, sender: weakSelf).show()
                            }
                        }
                    }
                }catch {
                    Loaf("转寄失败，水木返回异常", state: .error, sender: weakSelf).show()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
