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

struct SMBridgeError : Error {
    let code: Int
    let message: String
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

class SMPostViewControllerV4 : SMViewController, WKScriptMessageHandler {

    @objc var post:SMPost?
    var postForAction: SMPost?
    var webView:WKWebView!
    
    var bridges: [String: (Any) -> Future<Any, SMBridgeError>] = [:]
    var cancellables: [Int: AnyCancellable] = [:]
    var promiseID:Int = 0
   
    override func viewDidLoad() {
        self.title = "Post"

        bridges = ["ajax": self._ajax,
                   "postInfo": self._postInfo,
                   "reply": self._reply,
                   "activity": self._activity,
                   "__nope": self._nope]
        
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "nativeBridge")
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.view.addSubview(self.webView)
        let urlString = "http://10.0.0.11:3000/"
        let request = URLRequest(url: URL(string: urlString)!)
        self.webView.load(request)
        debugPrint("post: ", post ?? "nil");
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
            guard let fn = bridges[methodName] else {
                sendMessageToWeb(callbackID: callbackID, code: -1, data: "", message: "不存在的Bridge方法[\(methodName)]")
                return
            }
            let parameters = body["parameters"] as Any
            let index = promiseID
            var tryToRemoveSync = false
            promiseID += 1
            cancellables[index] = fn(parameters).sink(receiveCompletion: { ret in
                switch(ret) {
                case .finished:
                    debugPrint("success")
                case let .failure(error):
                    self.sendMessageToWeb(callbackID: callbackID, code: error.code, data: [:], message: error.message)
                    debugPrint("failure", error)
                }
                if((self.cancellables.removeValue(forKey: index)) == nil) {
                    tryToRemoveSync = true
                }
                debugPrint(self.cancellables)
            }, receiveValue: { data in
                self.sendMessageToWeb(callbackID: callbackID, code: 0, data: data, message: "")
            })
            if (tryToRemoveSync) {
                self.cancellables.removeValue(forKey: index)
            }
        }
    }
    
    func sendMessageToWeb(callbackID: Int, code: Int, data: Any, message: String) {
        do {
//            throw SMBridgeError(code: -1, message: "debug") // test
            let rspData = try JSONSerialization.data(withJSONObject: ["code": code, "data": data, "message": message], options: .prettyPrinted)
            let rspString = String(data: rspData, encoding: .utf8) ?? "{code:1, message: 'JSON转换异常'}"
            let js = "window.$xCallback(\(callbackID), \(rspString))"
            self.webView.evaluateJavaScript(js) { debugPrint($0 ?? "", $1 ?? "") }
//            debugPrint("js: \(js)")
        } catch {
            let js = "window.$xCallback(\(callbackID), {code: -1, message: '序列化Bridge返回值异常'})"
            self.webView.evaluateJavaScript(js) { debugPrint($0 ?? "", $1 ?? "") }
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
//                            debugPrint("rsp: ", rsp.result)
                            do {
                                if let data = try rsp.result.get() {
                                    let ct = rsp.response?.headers.value(for: "content-type")
                                    debugPrint("ct", ct!)
                                    var html: String = ""
                                    if ((ct?.uppercased().contains("GBK"))!) {
//                                        html = SMUtils.s
                                        html = SMUtils.gb2312Data2String(data);
//                                        let cfEncoding = CFStringEncodings.GB_18030_2000
//                                        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
//                                        html = NSString(data: data, encoding: encoding)! as String
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
        return Future { promise in
            if let _postForAction = parameters as? Dictionary<String, AnyObject> {
                self.postForAction = SMPost.init(json: _postForAction)
                if (!SMAccountManager.instance()!.isLogin) {
                    self.performSelector(afterLogin: #selector(self.reply))
                } else {
                    self.reply()
                }
                promise(.success(true))
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "无效的帖子信息")))
            }
        }
    }
    
    func _postInfo(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            promise(.success([
                              "pid": self.post?.pid as Any,
                              "gid": self.post?.gid as Any,
                              "board": self.post?.board?.name as Any
            ]))
        }
    }
    
    func _activity(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            if let _postForAction = parameters as? Dictionary<String, AnyObject> {
                self.postForAction = SMPost.init(json: _postForAction)
                let p = self.postForAction!
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
                        self.forwardActivity()
                    }
                    debugPrint(activityType?.rawValue ?? "no activity")
                }
                self.present(activity, animated: true, completion: nil)
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
    func forwardActivity() {
        let alert = UIAlertController(title: "转寄", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "请输入转寄地址"
        })
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0],
                let userText = textField.text else { return }
            debugPrint("alert", userText)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
