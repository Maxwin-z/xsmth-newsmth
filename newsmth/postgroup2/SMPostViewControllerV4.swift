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
import SafariServices

struct SMBridgeError : Error {
    let code: Int
    let message: String
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

extension Notification.Name {
    static let webNotification = Notification.Name("webNotification")
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

class SMPostViewControllerV4 : SMViewController, WKURLSchemeHandler, WKScriptMessageHandler, WKNavigationDelegate {

    // hold viewcontroller for webview to save states
    var holdMyself: [String: ((Any) -> Future<Any, SMBridgeError>)] = [:]
    
    let mmkv = MMKV.default()
    
    @objc var post:SMPost?
    @objc var fromBoard:Bool = false
    @objc var single:Bool = false
    var postForAction: SMPost?
    var webView:WKWebView!
    var refreshControl: UIRefreshControl!
    
    var cancellables: [Int: AnyCancellable] = [:]
    var promiseID:Int = 0
    var bridges:[String: ((Any) -> Future<Any, SMBridgeError>)] = [:]
    
    // button bar
    let buttonHeight: CGFloat = 44.0
    let pickerHeight: CGFloat = 180.0
    let padding: CGFloat = 10.0
    var viewForBottomBar: UIView!
    var buttonForPagination: UIButton!
    var viewForPagePicker: UIView!
    var pagePicker: UIPickerView!
    
    var pageUrl = "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/build/index.html"
    
    // page
    var pageNumber: Int = 0
    var totalPageNumber: Int = 0
    
    override func viewDidLoad() {
        self.title = self.post?.title ?? "正在加载..."
        if (!self.fromBoard) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onRightBarButtonClick))
        }

//        bridges = ["ajax": self._ajax]    // will cause memory leak
        holdMyself = ["nope": self._nope]
        
        let leakAvioder = LeakAvoider(messageHandler: self, schemeHandler: self)
        let userContentController = WKUserContentController()
        userContentController.add(leakAvioder, name: "nativeBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        config.setURLSchemeHandler(leakAvioder, forURLScheme: "ximg")
//        config.setURLSchemeHandler(leakAvioder, forURLScheme: "xfont")

        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.webView.navigationDelegate = self;
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView.isOpaque = false
        self.webView.backgroundColor = SMTheme.colorForBackground()
        self.webView.scrollView.backgroundColor = SMTheme.colorForBackground()
        self.webView.scrollView.delegate = self
        self.view.addSubview(self.webView)
//        let urlString = "http://10.0.0.11:3000/"
//        let urlString = "http://172.16.232.34:3000/"
//        let urlString = "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/build/index.html"
        let request = URLRequest(url: URL(string: pageUrl)!)
        self.webView.load(request)
        debugPrint("post: ", post ?? "nil");
        
        // add refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        self.webView.scrollView.addSubview(refreshControl)
        
        
        self.viewForBottomBar = makeupViewForButtomBar()
        self.viewForPagePicker = makeupPagePickerView()
        self.view.addSubview(self.viewForBottomBar)
        self.view.addSubview(self.viewForPagePicker)
        
        self.viewForBottomBar.isHidden = true
        self.viewForPagePicker.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onWebNotification), name: .webNotification, object: nil)
    }
    
    override func setupTheme() {
        super.setupTheme();
        self.viewForPagePicker.backgroundColor = SMTheme.colorForHighlightBackground()
        self.viewForBottomBar.backgroundColor = SMTheme.colorForHighlightBackground()
        notificationToWeb(messageName: "THEME_CHANGE", data: themeConfig())
    }
    
    @objc
    public func removeMe() {
        self.notificationToWeb(messageName: "PAGE_CLOSE", data: true);
        NotificationCenter.default.removeObserver(self)
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // force to unload after 3s
            weakSelf?.holdMyself.removeAll()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(_: animated)
        if(self.isMovingFromParent) {
            self.removeMe()
        }
    }
    
    deinit {
        self.webView.stopLoading()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeBridge")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if (url.absoluteString == pageUrl) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                let safari = SFSafariViewController(url: url)
                safari.modalPresentationStyle = .automatic
                self.present(safari, animated: true, completion: nil)
            }
        }
    }
    
    @objc
    func onRefresh() {
        notificationToWeb(messageName: "PAGE_REFRESH", data: true)
        self.refreshControl.endRefreshing()
    }
    
    @objc
    func onRightBarButtonClick() {
        let vc = SMBoardViewController()
        vc.board = self.post?.board!
        if (SMConfig.iPadMode()) {
            SMMainViewController.instance()?.setRoot(vc)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc
    func onPaginationButtonClick() {
        if (self.totalPageNumber > 0) {
            showPagePicker()
        }
    }
    
    func showPagePicker() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewForPagePicker.isHidden = false
            var frame = self.viewForPagePicker.frame
            frame.origin.y = self.view.bounds.height - self.viewForPagePicker.frame.height
            self.viewForPagePicker.frame = frame
        }, completion: {_ in
            self.pagePicker.selectRow(self.pageNumber - 1, inComponent: 0, animated: false)
        })
    }
    
    @objc func hidePagePicker() {
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.viewForPagePicker.frame
            frame.origin.y = self.view.bounds.height
            self.viewForPagePicker.frame = frame
        }, completion: { _ in
            self.viewForPagePicker.isHidden = true
        })
    }
    
    @objc func onPagePickerConfirm() {
        let page = self.pagePicker.selectedRow(inComponent: 0) + 1
        self.notificationToWeb(messageName: "PAGE_SELECTED", data: page)
        self.hidePagePicker()
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
        buttonForPagination.addTarget(self, action: #selector(onPaginationButtonClick), for: .touchUpInside)
        
        v.addSubview(buttonForBack)
        v.addSubview(buttonForTop)
        v.addSubview(buttonForPagination)
        
        v.backgroundColor = SMTheme.colorForHighlightBackground()
        return v
    }
    
    func makeupPagePickerView() -> UIView {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: buttonHeight + pickerHeight))
        v.autoresizingMask = [.flexibleWidth]
        let buttonForCancel = UIButton(type: .system)
        buttonForCancel.setTitle("取消", for: .normal)
        buttonForCancel.sizeToFit()
        var frame = buttonForCancel.frame
        frame.origin.x = padding
        buttonForCancel.frame = frame

        let buttonForConfirm = UIButton(type: .system)
        buttonForConfirm.setTitle("确认", for: .normal)
        buttonForConfirm.sizeToFit()
        frame = buttonForConfirm.frame
        frame.origin.x = self.view.bounds.width - buttonForConfirm.frame.width - padding
        buttonForConfirm.frame = frame
        buttonForConfirm.autoresizingMask = [.flexibleLeftMargin]

        buttonForCancel.addTarget(self, action: #selector(hidePagePicker), for: .touchUpInside)
        buttonForConfirm.addTarget(self, action: #selector(onPagePickerConfirm), for: .touchUpInside)
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: buttonHeight, width: self.view.frame.width, height: pickerHeight))
        v.addSubview(picker)
        picker.autoresizingMask = [.flexibleWidth]
        picker.dataSource = self
        picker.delegate = self
        self.pagePicker = picker

        v.addSubview(buttonForCancel)
        v.addSubview(buttonForConfirm)
        
        v.backgroundColor = SMTheme.colorForHighlightBackground()
        
        return v
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        debugPrint(urlSchemeTask.request)
        guard var urlString = urlSchemeTask.request.url?.absoluteString else { return }
        debugPrint("urlScheme:", urlString)
        if (urlString == "ximg://LanTingXiHei_GBK.TTF") {
            guard let fontUrl = Bundle.main.url(forResource: "LanTingXiHei_GBK", withExtension: "TTF") else { return }
            do {
                let data = try Data(contentsOf: fontUrl)
                let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: "font/opentype", expectedContentLength: data.count, textEncodingName: nil)
                urlSchemeTask.didReceive(urlResponse)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            } catch {
                debugPrint("xfont error", error)
            }
            return
        }
        
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
            if (methodName == "log")  { fn = self._log}
            if (methodName == "download")  { fn = self._download}
            if (methodName == "login")  { fn = self._login}
            if (methodName == "pageNumberChanged") { fn = self._pageNumberChanged}
            if (methodName == "getThemeConfig") { fn = self._getThemeConfig}
            if (methodName == "setStorage") { fn = self._setStorage}
            if (methodName == "getStorage") { fn = self._getStorage}
            if (methodName == "removeStorage") { fn = self._removeStorage}
            if (methodName == "scrollTo") { fn = self._scrollTo}
            if (methodName == "scrollBy") { fn = self._scrollBy}

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
        if (type(of: data) == String.self || type(of: data) == String?.self) {
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
    
    @objc
    func onWebNotification(notification: Notification) {
        debugPrint(343, notification.userInfo ?? "nil")
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
                                    let ct = opts["encoding"] as? String ?? rsp.response?.headers.value(for: "content-type")
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
            guard let weakSelf = self else { return }
            guard let post = weakSelf.post else { return }
            promise(.success([
                    "pid": post.pid as Any,
                    "gid": post.gid as Any,
                    "board": post.board?.name as Any,
                    "title": post.title as Any,
                    "single": weakSelf.single as Bool
            ]))
        }
    }
    
    func _activity(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future {[weak self] promise in
            guard let weakSelf = self else { return }
            if let _postForAction = parameters as? Dictionary<String, AnyObject> {
                weakSelf.postForAction = SMPost.init(json: _postForAction)
                guard let p = self?.postForAction else {
                    promise(.failure(SMBridgeError(code: -1, message: "page unloaded")))
                    return
                }
                let singleAuthor = SMSingleAuthorActivity()
                let forward = SMForwardActivity()
                let forwardAll = SMForwardAllActivity()
                let mailTo = SMMailToActivity()
                let spam = SMSpamActivity()
                let urlString = "https://m.newsmth.net/article/\(p.board.name!)/single/\(p.pid)/0"
                let url = URL(string: urlString)
                var activities = [singleAuthor, forward, forwardAll, mailTo, spam]
                if (p.author == SMAccountManager.instance()?.name) {
                    let edit = SMEditActivity()
                    let delete = SMDeleteActivity()
                    activities.append(edit)
                    activities.append(delete)
                }
                let activity = UIActivityViewController(activityItems: [
                    p.content!, url!], applicationActivities: activities)
                activity.overrideUserInterfaceStyle = SMConfig.enableDayMode() ? .light : .dark
                activity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    if !completed {
                        return
                    }
                    let at = activityType?.rawValue ?? ""
                    if (at == SMActivityForwardActivity) {
                        weakSelf.forwardActivity(all: false)
                    }
                    if (at == SMActivityForwardAllActivity) {
                        weakSelf.forwardActivity(all: true)
                    }
                    if (at == SMActivityTypeMailToAuthor) {
                        weakSelf.mailtoWithPost()
                    }
                    if (at == SMActivitySpamActivity) {
                        Loaf.init("举报成功", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: weakSelf).show()
                    }
                    if (at == SMActivitySingleAuthorActivity) {
                        weakSelf.notificationToWeb(messageName: "SINGLE_AUTHOR", data: weakSelf.postForAction?.author ?? "")
                    }
                    if (at == SMActivityEditActivity) {
                        weakSelf.doEditPost()
                    }
                    if (at == SMActivityDeleteActivity) {
                        weakSelf.notificationToWeb(messageName: "DELETE_POST", data: weakSelf.postForAction?.pid ?? 0)
                    }
                    debugPrint(activityType?.rawValue ?? "no activity")
                }
                if (SMUtils.isPad()) {
                    activity.modalPresentationStyle = .popover
//                    SMIPadSplitViewController.instance()?.present(activity, animated: true, completion: nil)
                    weakSelf.present(activity, animated: true, completion: nil)
                    if let popover = activity.popoverPresentationController {
                        popover.sourceView = weakSelf.view
                        popover.sourceRect = CGRect(x: weakSelf.view.bounds.width / 2, y: weakSelf.view.bounds.height, width: 0.0, height: 0.0)
                    }
                } else {
                    weakSelf.present(activity, animated: true, completion: nil)
                }
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
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            if let data = parameters as? [String: Any] {
                if let type = data["type"] as? Int,
                    let message = data["message"] as? String {
                    var state: Loaf.State = .info
                    if (type == 0) {
                        state = .success
                    } else if (type == 1) {
                        state = .error
                    }
                    Loaf(message, state: state, sender: weakSelf).show()
                    return promise(.success(true))
                }
            }
            promise(.success(false))
        }
    }
    
    func _log(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            if let msg = parameters as? String {
                debugPrint("[WebView]: ", msg)
                promise(.success(true))
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
                        if (XImageViewCache.sharedInstance()?.getData(urlString) != nil) {
                            promise(.success(true))
                            return
                        }
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
                            
                            // this md5 is the pig.gif, show file download fail via www smth
                            if (SMUtils.md5(data)  == "38740b15ae0d27bdc1a351179e15f25b") {
                                promise(.failure(SMBridgeError(code: -2, message: "附件下载错误")))
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
        return Future { [weak self] promise in
            self?.afterLoginSuccess({
                promise(.success(true))
            }) {
                promise(.success(false))
            }
        }
    }
    
    func _pageNumberChanged(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            guard let parameters = parameters as? [String: Int] else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数列表")))
                return
            }
            guard let page = parameters["page"],
                let total = parameters["total"]
            else {
                promise(.failure(SMBridgeError(code: -1, message: "数据格式不正确")))
                return
            }
            
            weakSelf.pageNumber = page
            if (total > 0) {
                weakSelf.totalPageNumber = total
            }
            if (total == 1) {
                weakSelf.hideBottomBar()
            }
            
            weakSelf.buttonForPagination.setTitle("\(page)/\(weakSelf.totalPageNumber)", for: .normal)
            weakSelf.pagePicker.reloadAllComponents()
            promise(.success(true))
        }
    }
    
    func _getThemeConfig(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            if let weakSelf = self {
                promise(.success(weakSelf.themeConfig()))
                return
            }
            promise(.success(false))
        }
    }

    func _setStorage(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let parameters = parameters as? [String: Any] else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数")))
                return
            }
            guard let key = parameters["key"] as? String else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            if let value = parameters["value"] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: ["value": value], options: .prettyPrinted)
                    self?.mmkv.set(data, forKey: key)
                    promise(.success(true))
                } catch {
                    promise(.failure(SMBridgeError(code: -1, message: "序列化错误\(error.localizedDescription)")))
                }
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数，缺少value")))
            }
        }
    }
    
    func _getStorage(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else {
                promise(.success(false))
               return
            }
            guard let key = parameters as? String else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            guard let data = weakSelf.mmkv.data(forKey: key) else {
                promise(.failure(SMBridgeError(code: -1, message: "数据不存在")))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let value = json["value"] {
                    promise(.success(value))
                } else {
                    promise(.failure(SMBridgeError(code: -1, message: "数据格式不正确")))
                }
            } catch {
                promise(.failure(SMBridgeError(code: -1, message: "解析错误\(error.localizedDescription)")))
            }
        }
    }
    
    func _removeStorage(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let key = parameters as? String else {
                promise(.failure(SMBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            self?.mmkv.removeValue(forKey: key)
            promise(.success(true))
        }
    }

    func _nope(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { promise in
            promise(.success(true))
        }
    }
    
    func _scrollTo(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let point = parameters as? [String: Int] else {
                promise(.failure(SMBridgeError(code: -1, message: "参数错误")))
                return
            }
            if let x = point["x"], let y = point["y"] {
                self?.webView.scrollView.setContentOffset(CGPoint(x: x, y: y - (Int)(self?.topbarHeight ?? 0)), animated: true)
                promise(.success(true))
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "参数错误: (x, y)")))
            }
        }
    }
    
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func _scrollBy(parameters: Any) -> Future<Any, SMBridgeError> {
        return Future { [weak self] promise in
            guard let point = parameters as? [String: Int] else {
                promise(.failure(SMBridgeError(code: -1, message: "参数错误")))
                return
            }
            if let x = point["x"], let y = point["y"], let scrollView = self?.webView.scrollView {
                let point = scrollView.contentOffset
                scrollView.setContentOffset(CGPoint(x: (Int)(point.x) + x, y: (Int)(point.y) + y), animated: true)
                promise(.success(true))
            } else {
                promise(.failure(SMBridgeError(code: -1, message: "参数错误: (x, y)")))
            }
        }
    }

    /// activity methods
    @objc
    func forwardActivity(all: Bool) {
        self.afterLoginSuccess({
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
                SMAF.request(url, method: .post, parameters: ["target": userText, "threads": all ? "on" : ""]).response { response in
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
        }) {
            
        }
    }
    
    @objc
    func mailtoWithPost() {
        self.afterLoginSuccess({
            guard let p = self.postForAction else { return }
            let vc = SMMailComposeViewController()
            let mail = SMMailItem()
            mail.title = "Re: " +  p.title
            mail.content = p.content
            mail.author = p.author
            vc.mail = mail
            let nvc = P2PNavigationController(rootViewController: vc)
            self.view.window?.rootViewController?.present(nvc, animated: true, completion: nil)
        }) {
            //
        }
    }
    
    @objc
    func doEditPost() {
        let writer = SMWritePostViewController()
        writer.editPost = self.postForAction
        let nvc = P2PNavigationController.init(rootViewController: writer)
        if (SMConfig.iPadMode()) {
            SMIPadSplitViewController.instance()?.present(nvc, animated: true, completion: nil)
        } else {
            self.present(nvc, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate
extension SMPostViewControllerV4: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.totalPageNumber
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d", row + 1)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        debugPrint(row)
    }
}

// MARK: - ScrollViewDelegate
extension SMPostViewControllerV4: UIScrollViewDelegate {
    /// scrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 100) {
            self.showBottomBar()
        } else if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0) {
            self.hideBottomBar()
        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        debugPrint("252", point)
        if (point.y > 0) {
            self.showBottomBar()
        }
    }
    
    func hideBottomBar() {
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.viewForBottomBar.frame
            frame.origin.y = self.view.bounds.height
            self.viewForBottomBar.frame = frame
        }) { (_) in
            self.viewForBottomBar.isHidden = true
        }
    }

    func showBottomBar() {
        self.viewForBottomBar.isHidden = false
        UIView.animate(withDuration: 0.5) {
            var frame = self.viewForBottomBar.frame
            frame.origin.y = self.view.bounds.height - self.viewForBottomBar.frame.height
            self.viewForBottomBar.frame = frame
        }
    }
}
// MARK: - Theme
extension SMPostViewControllerV4 {
    func themeConfig() -> [String:String] {
        let font = SMConfig.postFont() ?? UIFont.systemFont(ofSize: 14.0)
        let fontFamily = font.fontName
        let fontSize = String(format: "%dpx", (Int)(font.pointSize))
        let lineHeight = String(format: "%dpx", (Int)(font.lineHeight * 1.2))
        let bgColor = color2hex(color: SMTheme.colorForBackground())
        let textColor = color2hex(color: SMTheme.colorForPrimary())
        let tintColor = color2hex(color: SMTheme.colorForTintColor())
        let quoteColor = color2hex(color: SMTheme.colorForQuote())
        return [
            "fontFamily": fontFamily,
            "fontSize": fontSize,
            "lineHeight": lineHeight,
            "bgColor": bgColor,
            "textColor": textColor,
            "tintColor": tintColor,
            "quoteColor": quoteColor
        ]
    }
    
    func color2hex(color: UIColor) -> String {
        var rf: CGFloat = 0.0
        var gf: CGFloat = 0.0
        var bf: CGFloat = 0.0
        var af: CGFloat = 0.0
        color.getRed(&rf, green: &gf, blue: &bf, alpha: &af)
        let r = (Int)(255.0 * rf)
        let g = (Int)(255.0 * gf)
        let b = (Int)(255.0 * bf)
        let a = (Int)(255.0 * af)
        return String(format: "#%02x%02x%02x%02x", r, g, b, a)
    }
}
