//
//  SMLoginViewControllerV2.swift
//  newsmth
//
//  Created by WenDong on 2020/8/9.
//  Copyright © 2020 nju. All rights reserved.
//

import UIKit
import WebKit

class SMLoginViewControllerV2: XWebController{
    typealias fn = () -> Void
    
    var target: NSObject?
    var selector: Selector?
    var successFunc: fn?
    var failFunc: fn?
    
    override func viewDidLoad() {
        self.url = URL(string: "https://m.newsmth.net/index")
        super.viewDidLoad()
    }
    
    override func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            cookies.forEach { cookie in
                debugPrint(2222, cookie)
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            SMAccountManager.instance()?.setCookies(cookies)
            if (SMAccountManager.instance()?.isLogin == true) {
                self?.loginSuccess()
            }
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func loginSuccess() {
        if (target != nil && selector != nil) {
            target?.perform(selector)
        }
        if (self.successFunc != nil) {
            self.successFunc!()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     - (void)setAfterLoginTarget:(id)target selector:(SEL)aSelector;
     - (void)loginWithSuccess:(void(^)())success fail:(void(^)())fail;
     */
    @objc func afterLogin(target: NSObject, selector: Selector) -> Void {
        self.target = target
        self.selector = selector
    }
    @objc func loginWith(success: @escaping () -> Void, fail: @escaping () -> Void) {
        self.successFunc = success
        self.failFunc = fail
    }
}
