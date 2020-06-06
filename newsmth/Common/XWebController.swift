//
//  XWebController.swift
//  newsmth
//
//  Created by WenDong on 2020/5/4.
//  Copyright © 2020 nju. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import Loaf
import SafariServices
import UIKit
import WebKit
import StoreKit


struct XBridgeError: Error {
    let code: Int
    let message: String
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

class XLeakAvoider: NSObject, WKScriptMessageHandler, WKURLSchemeHandler {
    @objc var url: URL?
    weak var messageHandler: WKScriptMessageHandler?
    weak var schemeHandler: WKURLSchemeHandler?
    init(messageHandler: WKScriptMessageHandler, schemeHandler: WKURLSchemeHandler) {
        self.messageHandler = messageHandler
        self.schemeHandler = schemeHandler
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        messageHandler?.userContentController(
            userContentController, didReceive: message
        )
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        schemeHandler?.webView(webView, start: urlSchemeTask)
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        schemeHandler?.webView(webView, stop: urlSchemeTask)
    }
}

typealias XBridgeFunc = ((Any) -> Future<Any, XBridgeError>)

class XWebController: SMViewController, WKURLSchemeHandler, WKScriptMessageHandler, WKNavigationDelegate {
    @objc var url: URL?
    // hold viewcontroller for webview to save states
    var holdMyself: [String: XBridgeFunc] = [:]

    let mmkv = MMKV.default()

    var webView: WKWebView!
    var refreshControl: UIRefreshControl!

    var cancellables: [Int: AnyCancellable] = [:]
    var promiseID: Int = 0
    var bridges: [String: XBridgeFunc] = [:]

//    var pageUrl = "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/build/index.html"
//    var pageUrl = "http://10.0.0.11:3000/"

    func regisgerBridges(bs: [String: XBridgeFunc]) {
        bridges.merge(bs) { (_, new) -> XBridgeFunc in
            new
        }
    }

    override func viewDidLoad() {
        title = "正在加载..."
        holdMyself = ["nope": _nope]

        let leakAvioder = XLeakAvoider(messageHandler: self, schemeHandler: self)
        let userContentController = WKUserContentController()
        userContentController.add(leakAvioder, name: "nativeBridge")

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        config.setURLSchemeHandler(leakAvioder, forURLScheme: "ximg")
//        config.setURLSchemeHandler(leakAvioder, forURLScheme: "xfont")

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = SMTheme.colorForBackground()
        webView.scrollView.backgroundColor = SMTheme.colorForBackground()
        view.addSubview(webView)
//        let urlString = "http://10.0.0.11:3000/"
//        let urlString = "http://172.16.232.34:3000/"
//        let urlString = "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/build/index.html"
        if url != nil {
            let request = URLRequest(url: url!)
            webView.load(request)
        }

        // add refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)

        regisgerBridges(bs: [
            "setTitle": _setTitle,
            "ajax": _ajax,
            "unloaded": _unloaded,
            "toast": _toast,
            "log": _log,
            "download": _download,
            "login": _login,
            "getThemeConfig": _getThemeConfig,
            "setStorage": _setStorage,
            "getStorage": _getStorage,
            "removeStorage": _removeStorage,
            "scrollTo": _scrollTo,
            "scrollBy": _scrollBy,
            "open": _open,
            "close": _close,
        ])

        navigationController?.presentationController?.delegate = self
        
        //
//        fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationToWeb(messageName: "willAppear", data: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToWeb(messageName: "didAppear", data: true)
        if navigationController != nil, navigationController?.viewControllers.count == 1, navigationController?.presentingViewController?.presentedViewController == navigationController {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonClick))
        }
    }
    

    @objc
    func onDoneButtonClick() {
        navigationController?.dismiss(animated: true, completion: nil)
        dismiss(animated: false, completion: nil)
        removeMe()
    }

//    func methodPointer<T: AnyObject>(obj: T, m: @escaping(T) -> XBridgeFunc, parameters: Any) -> XBridgeFunc {
//        return {[weak obj] in
//            m(obj!)(parameters)
//        }
//    }
    override func setupTheme() {
        super.setupTheme()
        notificationToWeb(messageName: "THEME_CHANGE", data: themeConfig())
        webView.backgroundColor = SMTheme.colorForBackground()
        webView.scrollView.backgroundColor = SMTheme.colorForBackground()
    }

    @objc
    public func removeMe() {
        notificationToWeb(messageName: "PAGE_CLOSE", data: true)
        NotificationCenter.default.removeObserver(self)
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // force to unload after 3s
            weakSelf?.holdMyself.removeAll()
            weakSelf?.bridges.removeAll()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToWeb(messageName: "willDisappear", data: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(_: animated)
        if isMovingFromParent {
            removeMe()
        }
    }

    deinit {
        self.webView.stopLoading()
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeBridge")
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if self.url != nil, url.absoluteString == self.url!.absoluteString {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                if url.absoluteString == "about:blank" {
                    return
                }
                let safari = SFSafariViewController(url: url)
                if SMUtils.isPad() {
                    view.window?.rootViewController?.present(safari, animated: true, completion: nil)
                } else {
                    present(safari, animated: true, completion: nil)
                }
            }
        }
    }

    @objc
    func onRefresh() {
        notificationToWeb(messageName: "PAGE_REFRESH", data: true)
        refreshControl.endRefreshing()
    }

    func webView(_: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        debugPrint(urlSchemeTask.request)
        guard var urlString = urlSchemeTask.request.url?.absoluteString else { return }
        debugPrint("urlScheme:", urlString)
        if urlString == "ximg://LanTingXiHei_GBK.TTF" {
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

    func webView(_: WKWebView, stop _: WKURLSchemeTask) {}

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("message: ", message.name, message.body)
        if message.name != "nativeBridge" {
            // unexpected message
            return
        }
        if let body = message.body as? [String: AnyObject] {
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
            cancellables[index] = fn(parameters).sink(receiveCompletion: { [weak self] ret in
                guard let weakSelf = self else {
                    return
                }

                switch ret {
                case .finished:
                    debugPrint("success")
                case let .failure(error):
                    weakSelf.sendMessageToWeb(callbackID: callbackID, code: error.code, data: [:], message: error.message)
                    debugPrint("failure", error)
                }
                if weakSelf.cancellables.removeValue(forKey: index) == nil {
                    tryToRemoveSync = true
                }
                debugPrint(weakSelf.cancellables)
            }, receiveValue: { [weak self] data in
                self?.sendMessageToWeb(callbackID: callbackID, code: 0, data: data, message: "")
            })
            if tryToRemoveSync {
                cancellables.removeValue(forKey: index)
            }
        }
    }

    func notificationToWeb(messageName: String, data: Any) {
        var param: String?
        if type(of: data) == String.self || type(of: data) == String?.self {
            if let data = data as? String {
                param = "'\(data)'"
            }
        }
        if data is Int || data is Float || data is Double {
            param = String(describing: data)
        }
        if data is [Any] || data is [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                param = String(data: jsonData, encoding: .utf8) ?? ""
            } catch {}
        }
        if param == nil {
            param = ""
        }

        let js = "window.$x_publish('\(messageName)', \(param!))"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    @objc
    func onWebNotification(notification: Notification) {
        debugPrint(343, notification.userInfo ?? "nil")
    }

    func sendMessageToWeb(callbackID: Int, code: Int, data: Any, message: String) {
        weak var wealSelf = self
        do {
//            throw XBridgeError(code: -1, message: "debug") // test
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

    func _ajax(parameters: Any) -> Future<Any, XBridgeError> {
        return Future<Any, XBridgeError> { promise in
            if let opts = parameters as? [String: AnyObject] {
                let headers = HTTPHeaders(opts["headers"] as? [String: String] ?? [:])
                if let url = opts["url"] as? String {
                    SMAF.request(url, headers: headers).response { rsp in
                        if case let .failure(error) = rsp.result {
                            debugPrint(error.errorDescription ?? "")
                            promise(.failure(XBridgeError(code: -1, message: "AFError:" + (error.errorDescription ?? "unknown error"))))
                        } else {
                            do {
                                if let data = try rsp.result.get() {
                                    let ct = opts["encoding"] as? String ?? rsp.response?.headers.value(for: "content-type")
                                    debugPrint("ct", ct!)
                                    var html: String = ""
                                    if (ct?.uppercased().contains("GBK"))! {
                                        html = SMUtils.gb2312Data2String(data)
                                    } else {
                                        html = String(data: data, encoding: .utf8)!
                                    }
                                    promise(.success(html))
                                } else {
                                    promise(.failure(XBridgeError(code: -1, message: "请求回包为空")))
                                }
                            } catch {
                                promise(.failure(XBridgeError(code: -1, message: "请求回包错误: " + (error.asAFError?.errorDescription ?? "unknown error"))))
                            }
                        }
                    }
                } else {
                    promise(.failure(XBridgeError(code: -1, message: "错误的请求地址")))
                }
            } else {
                promise(.failure(XBridgeError(code: -1, message: "错误的Bridge参数")))
            }
        }
    }

    func _setTitle(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            if let title = parameters as? String {
                self?.title = title
            }
            promise(.success(true))
        }
    }

    func _unloaded(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            self?.holdMyself.removeAll()
            self?.bridges.removeAll()
            promise(.success(true))
        }
    }

    /**
     * [
     *  "type": enum(success = 0, error = 1, info = 2,
     *  "message": string
     * ]
     */
    func _toast(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            if let data = parameters as? [String: Any] {
                if let type = data["type"] as? Int,
                    let message = data["message"] as? String {
                    var state: Loaf.State = .info
                    if type == 0 {
                        state = .success
                    } else if type == 1 {
                        state = .error
                    }
                    Loaf(message, state: state, sender: weakSelf).show()
                    return promise(.success(true))
                }
            }
            promise(.success(false))
        }
    }

    func _log(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { promise in
            if let msg = parameters as? String {
                debugPrint("[WebView]: ", msg)
                promise(.success(true))
            }
            promise(.success(false))
        }
    }

    func _download(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            let weakSelf = self
            if let data = parameters as? [String: Any] {
                if let urlString = data["url"] as? String {
                    if let url = URL(string: urlString) {
                        if XImageViewCache.sharedInstance()?.getData(urlString) != nil {
                            promise(.success(true))
                            return
                        }
                        let id = data["id"] as? Int ?? 0
                        SMAF.download(url).downloadProgress(queue: .main, closure: { progrss in
                            if id > 0 {
                                let data: [String: Any] = [
                                    "id": id,
                                    "progress": progrss.fractionCompleted,
                                    "completed": progrss.completedUnitCount,
                                    "total": progrss.totalUnitCount,
                                ]
                                weakSelf?.notificationToWeb(messageName: "DOWNLOAD_PROGRESS", data: data)
                            }
                        }).responseData(queue: .main, completionHandler: { response in
                            guard let data = response.value else {
                                guard case let .failure(error) = response.result else {
                                    promise(.failure(XBridgeError(code: -1, message: "下载失败")))
                                    return
                                }
                                promise(.failure(XBridgeError(code: -1, message: error.localizedDescription)))
                                return
                            }

                            // this md5 is the pig.gif, show file download fail via www smth
                            if SMUtils.md5(data) == "38740b15ae0d27bdc1a351179e15f25b" {
                                promise(.failure(XBridgeError(code: -2, message: "附件下载错误")))
                                return
                            }

                            if let _ = UIImage(data: data) {
                                XImageViewCache.sharedInstance()?.setImageData(data, forUrl: urlString)
                                promise(.success(true))
                            } else {
                                promise(.failure(XBridgeError(code: -2, message: "图片内容不正确")))
                            }
                        })
                    } else {
                        promise(.failure(XBridgeError(code: -1, message: "资源URL不正确")))
                    }
                } else {
                    promise(.failure(XBridgeError(code: -1, message: "参数错误，无URL")))
                }
            } else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误")))
            }
        }
    }

    func _login(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            self?.afterLoginSuccess({
                promise(.success(true))
            }) {
                promise(.success(false))
            }
        }
    }

    func _getThemeConfig(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            if let weakSelf = self {
                promise(.success(weakSelf.themeConfig()))
                return
            }
            promise(.success(false))
        }
    }

    func _setStorage(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let parameters = parameters as? [String: Any] else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数")))
                return
            }
            guard let key = parameters["key"] as? String else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            if let value = parameters["value"] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: ["value": value], options: .prettyPrinted)
                    self?.mmkv.set(data, forKey: key)
                    promise(.success(true))
                } catch {
                    promise(.failure(XBridgeError(code: -1, message: "序列化错误\(error.localizedDescription)")))
                }
            } else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数，缺少value")))
            }
        }
    }

    func _getStorage(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else {
                promise(.success(false))
                return
            }
            guard let key = parameters as? String else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            guard let data = weakSelf.mmkv.data(forKey: key) else {
                promise(.failure(XBridgeError(code: -1, message: "数据不存在")))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let value = json["value"] {
                    promise(.success(value))
                } else {
                    promise(.failure(XBridgeError(code: -1, message: "数据格式不正确")))
                }
            } catch {
                promise(.failure(XBridgeError(code: -1, message: "解析错误\(error.localizedDescription)")))
            }
        }
    }

    func _removeStorage(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let key = parameters as? String else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数，缺少key")))
                return
            }
            self?.mmkv.removeValue(forKey: key)
            promise(.success(true))
        }
    }

    func _nope(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { promise in
            promise(.success(true))
        }
    }

    func _open(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let parameters = parameters as? [String: Any] else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误")))
                return
            }
            guard let urlString = parameters["url"] as? String else {
                promise(.failure(XBridgeError(code: -1, message: "url不能为空")))
                return
            }
            guard let url = URL(string: urlString) else {
                promise(.failure(XBridgeError(code: -1, message: "非法的url")))
                return
            }
            let type = parameters["type"] as? Int ?? 0
            let vc = XWebController()
            vc.url = url
            vc.bridges = [:]
            if type == 0 {
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .automatic
                let nvc = P2PNavigationController(rootViewController: vc)
                if SMUtils.isPad() {
                    self?.view.window?.rootViewController?.present(nvc, animated: true, completion: nil)
                } else {
                    self?.present(nvc, animated: true, completion: nil)
                }
                promise(.success(true))
            }
        }
    }

    func _close(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            if self?.navigationController?.presentingViewController?.presentedViewController == self?.navigationController {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
            promise(.success(true))
        }
    }

    func _scrollTo(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let point = parameters as? [String: Int] else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误")))
                return
            }
            if let x = point["x"], let y = point["y"] {
                self?.webView.scrollView.setContentOffset(CGPoint(x: x, y: y - (Int)(self?.topbarHeight ?? 0)), animated: true)
                promise(.success(true))
            } else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误: (x, y)")))
            }
        }
    }

    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (navigationController?.navigationBar.frame.height ?? 0.0)
    }

    func _scrollBy(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let point = parameters as? [String: Int] else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误")))
                return
            }
            if let x = point["x"], let y = point["y"], let scrollView = self?.webView.scrollView {
                let point = scrollView.contentOffset
                scrollView.setContentOffset(CGPoint(x: (Int)(point.x) + x, y: (Int)(point.y) + y), animated: true)
                promise(.success(true))
            } else {
                promise(.failure(XBridgeError(code: -1, message: "参数错误: (x, y)")))
            }
        }
    }
}

// MARK: - Theme

extension XWebController {
    func themeConfig() -> [String: String] {
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
            "quoteColor": quoteColor,
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

extension XWebController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_: UIPresentationController) {
        removeMe()
    }
}

// MARK: - IAP

extension XWebController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            debugPrint("SK updatedTransactions", t.payment.productIdentifier, t.transactionState == .purchased,
                       t.transactionState == .restored)
            SKPaymentQueue.default().finishTransaction(t)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            debugPrint("SK product empty")
            return
        }
        let product = response.products[0]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        debugPrint("SK pay")
    }
    
    func fetchProducts() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()

//        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
//            debugPrint("SK No store receipt url")
//            return ;
//        }
//        do {
//            let receiptData = try Data(contentsOf: receiptURL)
//            // Custom method to work with receipts
//            let receiptString = receiptData.base64EncodedString(options: [])
//            debugPrint(receiptString)
//        } catch {
//            debugPrint(error)
//        }
        
//        let req = SKProductsRequest(productIdentifiers: ["me.maxwin.newsmth.proplus"])
//        req.delegate = self
//        req.start()
    }
}

