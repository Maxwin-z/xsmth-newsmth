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
    let code: Int?
    let message: String?
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

class SMPostViewControllerV4 : SMViewController, WKScriptMessageHandler {

    @objc var post:SMPost?
    var webView:WKWebView!
    
    var bridges: [String: (Any) -> Future<Dictionary<String, Any>, Error>] = [:]
    var cancellables: [Int: AnyCancellable] = [:]
   
    override func viewDidLoad() {
        self.title = "Post"

        bridges = ["ajax": self._ajax, "__nope": self._nope]
        
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
            debugPrint(body)
            let methodName = body["methodName"] as? String ?? "__nope"
//            let callbackID = body["callbackID"]
            let parameters = body["parameters"]
//            let methodName = "ajax"
//            let parameters = ["url": "https://m.newsmth.net"]
//            let parameters = [
//                "url": "https://www.newsmth.net/nForum/fav/0.json?_t=1580358795114" + String(format: "%f", Date().timeIntervalSince1970),
//                "headers": ["X-Requested-With": "XMLHttpRequest"]] as [String : Any]
            if let fn = bridges[methodName] {
                let index = cancellables.count
                cancellables[index] = fn(parameters as AnyObject).sink(receiveCompletion: { ret in
                    switch(ret) {
                    case .finished:
                        debugPrint("success")
                    case let .failure(error):
                        debugPrint("failure", error)
                    }
//                    self.cancellables.removeValue(forKey: index)
                    debugPrint(self.cancellables)
                }, receiveValue: { data in
                   debugPrint("\(methodName) success: \(data)")
                })
            }
        }
    }
    
    func _ajax(parameters: Any) -> Future<Dictionary<String, Any>, Error> {
        return Future<Dictionary<String, Any>, Error> { promise in
            if let opts = parameters as? Dictionary<String, AnyObject> {
                let headers = HTTPHeaders(opts["headers"] as? [String: String] ?? [:])
                if let url = opts["url"] as? String {
                    AF.request(url, headers: headers).response { resp in
                        if case let .failure(error) = resp.result {
                            debugPrint(error.errorDescription ?? "")
                            promise(.failure(SMBridgeError(code: -1, message: "AFError:" + (error.errorDescription ?? "unknown error"))))
                        } else {
                            debugPrint("rsp: ", resp.result)
                            do {
                                if let data = try resp.result.get() {
                                    let ct = resp.response?.headers.value(for: "content-type")
                                    debugPrint("ct", ct!)
                                    var html: String = ""
                                    if ((ct?.uppercased().contains("GBK"))!) {
                                        let cfEncoding = CFStringEncodings.GB_18030_2000
                                        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
                                        html = NSString(data: data, encoding: encoding)! as String
                                    } else {
                                        html = String(data: data, encoding: .utf8)!
                                    }
                                    promise(.success(["data": html as Any]))
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
    
    func _nope(parameters: Any) -> Future<Dictionary<String, Any>, Error> {
        return Future { promise in
            promise(.success([:]))
        }
    }
}
