//
//  SMPostViewControllerV4.swift
//  newsmth
//
//  Created by WenDong on 2020/1/28.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit
import Foundation
import WebKit
import Alamofire

class SMPostViewControllerV4 : SMViewController, WKScriptMessageHandler {

    @objc var post:SMPost?
    var webView:WKWebView!
    
    var bridges: [String: (Any) -> Int] = [:]
   
    override func viewDidLoad() {
        self.title = "Post"

        bridges = ["ajax": self._ajax]
        
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
//            let methodName = body["methodName"] as? String
//            let callbackID = body["callbackID"]
//            let parameters = body["parameters"]
            let methodName = "ajax"
            let parameters = ["url": "https://qq.com"]
            if let fn = bridges[methodName] {
                let ret = fn(parameters as AnyObject)
                debugPrint("ret: ", ret);
            }
        }
    }
    
    func _ajax(parameters: Any) -> Int {
        if let opts = parameters as? Dictionary<String, AnyObject> {
            if let url = opts["url"] as? String {
                AF.request(url).response {
                    response in debugPrint(response)
                }
            } else {
                return -1
            }
        }
        return 0
    }
    
}
