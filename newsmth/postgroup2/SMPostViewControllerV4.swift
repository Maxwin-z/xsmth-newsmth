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



class LeakAvoider : NSObject, WKScriptMessageHandler, WKURLSchemeHandler {
    
    weak var messageHandler: WKScriptMessageHandler?
    weak var schemeHandler: WKURLSchemeHandler?
    init(messageHandler:WKScriptMessageHandler, schemeHandler: WKURLSchemeHandler) {
        self.messageHandler = messageHandler
        self.schemeHandler = schemeHandler
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.messageHandler?.userContentController(
            userContentController, didReceive: message)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        self.schemeHandler?.webView(webView, start: urlSchemeTask)
    }
       
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        self.schemeHandler?.webView(webView, stop: urlSchemeTask)
    }
}

let mmkvKey_forwardTarget = "forwardTarget"

class SMPostViewControllerV4 : SMViewController, WKURLSchemeHandler, WKScriptMessageHandler, UIPickerViewDataSource, UIPickerViewDelegate {

    // hold viewcontroller for webview to save states
    var holdMyself: [String: ((Any) -> Future<Any, SMBridgeError>)] = [:]
    
    let mmkv = MMKV.default()
    
    @objc var post:SMPost?
    var postForAction: SMPost?
    var webView:WKWebView!
    
    var cancellables: [Int: AnyCancellable] = [:]
    var promiseID:Int = 0
    var bridges:[String: ((Any) -> Future<Any, SMBridgeError>)] = [:]
    
    // button bar
    let buttonHeight: CGFloat = 44.0
    let pickerHeight: CGFloat = 180.0
    var viewForBottomBar: UIView!
    var buttonForPagination: UIButton!
    var viewForPagePicker: UIView!
    
    override func viewDidLoad() {
        self.title = "Post"

        
//        bridges = ["ajax": self._ajax]    // will cause memory leak
        holdMyself = ["nope": self._nope]
        
        let leakAvioder = LeakAvoider(messageHandler: self, schemeHandler: self)
        let userContentController = WKUserContentController()
        userContentController.add(leakAvioder, name: "nativeBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        config.setURLSchemeHandler(leakAvioder, forURLScheme: "ximg")

        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.view.addSubview(self.webView)
        let urlString = "http://10.0.0.12:3000/"
        let request = URLRequest(url: URL(string: urlString)!)
        self.webView.load(request)
        debugPrint("post: ", post ?? "nil");
        
        // add refresh
        let refreshControl = UIRefreshControl()
        self.webView.scrollView.addSubview(refreshControl)
        
        self.viewForBottomBar = makeupViewForButtomBar()
        self.viewForPagePicker = makeupPagePickerView()
        self.view.addSubview(self.viewForBottomBar)
        self.view.addSubview(self.viewForPagePicker)
        
        self.viewForBottomBar.isHidden = true
        self.viewForPagePicker.isHidden = true
        
        if var protocols = Alamofire.Session.default.sessionConfiguration.protocolClasses {
            protocols.insert(SMURLProtocol.self, at: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(_: animated)
        if(self.isMovingFromParent) {
            self.notificationToWeb(messageName: "PAGE_CLOSE", data: true);
            weak var weakSelf = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // force to unload after 3s
                weakSelf?.holdMyself.removeAll()
            }
        }
    }
    
    deinit {
        self.webView.stopLoading()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeBridge")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        var frame = self.viewForBottomBar.frame
        frame.size.height = buttonHeight + self.view.safeAreaInsets.bottom
        frame.origin.y = self.view.bounds.height - frame.height
        self.viewForBottomBar.frame = frame
        
        frame = self.viewForPagePicker.frame
        frame.size.height = buttonHeight + pickerHeight + self.view.safeAreaInsets.bottom
        frame.origin.y = self.view.bounds.height - frame.height
        self.viewForPagePicker.frame = frame
    }
    
    func makeupViewForButtomBar() -> UIView {
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        let vHeight = buttonHeight + self.view.safeAreaInsets.bottom
        let v = UIView(frame: CGRect(x: 0.0, y: height - vHeight, width: width, height: vHeight))
        v.autoresizingMask = [.flexibleWidth]
        
        let buttons = ["icon_back", "icon_gotop"].map { icon -> UIButton in
            let button = UIButton(type: .system)
            let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.sizeToFit()
            button.center = CGPoint(x: button.frame.width / 2.0, y: buttonHeight / 2.0)
            return button
        }
        let buttonForBack = buttons[0]
        let buttonForTop = buttons[1]

        var frame = buttonForTop.frame
        frame.origin.x = width - frame.width
        buttonForTop.frame = frame
        buttonForTop.autoresizingMask = [.flexibleLeftMargin]
        
        buttonForPagination = UIButton(type: .system)
        buttonForPagination.frame = CGRect(x: buttonForBack.frame.width, y: 0, width: width - buttonForBack.frame.width - buttonForTop.frame.width, height: buttonHeight)
        buttonForPagination.setTitle("-/-", for: .normal)
        buttonForPagination.autoresizingMask = [.flexibleWidth]
        
        v.addSubview(buttonForBack)
        v.addSubview(buttonForTop)
        v.addSubview(buttonForPagination)
        
        v.backgroundColor = .lightGray
        return v
    }
    
    func makeupPagePickerView() -> UIView {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: buttonHeight + pickerHeight))
        let buttonForCancel = UIButton(type: .system)
        buttonForCancel.setTitle("取消", for: .normal)
        buttonForCancel.sizeToFit()

        let buttonForConfirm = UIButton(type: .system)
        buttonForConfirm.setTitle("确认", for: .normal)
        buttonForConfirm.sizeToFit()
        var frame = buttonForConfirm.frame
        frame.origin.x = self.view.bounds.width - buttonForConfirm.frame.width
        buttonForConfirm.frame = frame
        buttonForConfirm.autoresizingMask = [.flexibleLeftMargin]

        
        let picker = UIPickerView(frame: CGRect(x: 0, y: buttonHeight, width: self.view.frame.width, height: pickerHeight))
        v.addSubview(picker)
        picker.dataSource = self
        picker.delegate = self

        v.addSubview(buttonForCancel)
        v.addSubview(buttonForConfirm)
        
        v.backgroundColor = .red
        
        return v
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        debugPrint(urlSchemeTask.request)
        guard var urlString = urlSchemeTask.request.url?.absoluteString else { return }
        urlString = urlString.replacingOccurrences(of: "ximg://_?url=", with: "")
        guard let url = urlString.removingPercentEncoding else {
            debugPrint("ximg src decode error")
            return
        }
        
        if let data = XImageViewCache.sharedInstance()?.getData(url) {
            let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
            urlSchemeTask.didReceive(urlResponse)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } else {
            debugPrint("ximg not exists", url)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
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
            if (methodName == "unloaded")  { fn = self._unloaded}
            if (methodName == "toast")  { fn = self._toast}
            if (methodName == "download")  { fn = self._download}
            if (methodName == "login")  { fn = self._login}

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
    
    func notificationToWeb(messageName: String, data: Any) {
        var param: String? = nil
        if (type(of: data) == String.self) {
            if let data = data as? String {
                param = "'\(data)'"
            }
        }
        if (data is Int || data is Float || data is Double) {
            param = String(describing: data)
        }
        if (data is [Any] || data is [String:Any]) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                param = String(data: jsonData, encoding: .utf8) ?? ""
            } catch {
                
            }
        }
        if (param == nil) {
            param = ""
        }
        
        let js = "window.$x_publish('\(messageName)', \(param!))"
        self.webView.evaluateJavaScript(js, completionHandler: nil)
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
                    SMAF.request(url, headers: headers).response { rsp in
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

    func _unloaded(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            self?.holdMyself.removeAll()
            promise(.success(true))
        }
    }
    
    /**
     * [
     *  "type": enum(success = 0, error = 1, info = 2,
     *  "message": string
     * ]
     */
    func _toast(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            if let data = parameters as? [String: Any] {
                if let type = data["type"] as? Int,
                    let message = data["message"] as? String {
                    var state: Loaf.State = .info
                    if (type == 0) {
                        state = .success
                    } else if (type == 1) {
                        state = .error
                    }
                    Loaf(message, state: state, sender: self).show()
                    return promise(.success(true))
                }
            }
            promise(.success(false))
        }
    }

    func _download(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            let weakSelf = self
            if let data = parameters as? [String: Any] {
                if let urlString = data["url"] as? String {
                    if let url = URL(string: urlString) {
                        let id = data["id"] as? Int ?? 0
                        SMAF.download(url).downloadProgress(queue: .main, closure: { progrss in
                            if (id > 0) {
                                let data: [String: Any] = [
                                    "id": id,
                                    "progress": progrss.fractionCompleted,
                                    "completed": progrss.completedUnitCount,
                                    "total": progrss.totalUnitCount
                                ]
                                weakSelf?.notificationToWeb(messageName: "DOWNLOAD_PROGRESS", data: data)
                            }
                        }).responseData(queue: .main, completionHandler: { (response) in
                            guard let data = response.value else {
                                guard case let .failure(error) = response.result else {
                                    promise(.failure(SMBridgeError(code: -1, message: "下载失败")))
                                    return
                                }
                                promise(.failure(SMBridgeError(code: -1, message: error.localizedDescription)))
                                return
                            }
                            if let _ = UIImage(data: data) {
                                XImageViewCache.sharedInstance()?.setImageData(data, forUrl: urlString)
                                promise(.success(true))
                            } else {
                                promise(.failure(SMBridgeError(code: -2, message: "图片内容不正确")))
                            }
                        })
                    } else {
                        promise(.failure(SMBridgeError(code: -1, message: "资源URL不正确")))
                    }
                } else {
                    promise(.failure(SMBridgeError(code: -1, message: "参数错误，无URL")))
                }
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "参数错误")))
            }
        }
    }
    
    func _login(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            self.afterLoginSuccess({
                promise(.success(true))
            }) {
                promise(.success(false))
            }
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
            SMAF.request(url, method: .post, parameters: ["target": userText]).response { response in
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
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d", row)
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        debugPrint(row)
    }
}
