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
    
    weak var target: NSObject?
    var selector: Selector?
    var successFunc: fn?
    var failFunc: fn?
    
    override func viewDidLoad() {
        self.url = URL(string: "https://m.newsmth.net/index")
        super.viewDidLoad()
        self.title = "登录"
    }
    
    override func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        debugPrint("request: ", navigationAction.request.url ?? "")

        if ((navigationAction.request.url?.host ?? "").contains("google")) {
            debugPrint("cancel ", navigationAction.request.url ?? "")
            decisionHandler(.cancel)
            return
        }
        
        if (navigationAction.request.url?.host == "m.newsmth.net") {
            debugPrint(navigationAction.request.url?.absoluteString ?? "")
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
                cookies.forEach { cookie in
                    if (cookie.domain == ".newsmth.net") {
                        debugPrint(2222, cookie)
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }
                SMAccountManager.instance()?.setCookies(cookies)
                if (SMAccountManager.instance()?.isLogin == true) {
                    self?.loginSuccess()
                }
            }
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
           const selectors = [
              "#ad_container",
              ".slist.sec",
              ".logo.sp",
              ".menu.sp",
              ".menu.nav"
            ];
            selectors.forEach(sel => {
              [...document.querySelectorAll(sel)].forEach(dom => (dom.hidden = true));
            });

            const enlarges = ["#u_login", "#u_login input"];
            enlarges.forEach(sel => {
              [...document.querySelectorAll(sel)].forEach(dom => {
                dom.style = dom.style || {};
                dom.style.fontSize = "120%";
              });
            });
            
            const idEl = document.querySelector('[name="id"]');
            const passwdEl = document.querySelector('[name="passwd"]');
            const saveEl = document.querySelector('[name="save"]');
            saveEl.checked = true;
            const key = "_xsmth_userinfo";
            const userinfo = window.localStorage.getItem(key);
            if (userinfo) {
              try {
                const { id, passwd } = JSON.parse(userinfo);
                idEl.value = id;
                passwdEl.value = passwd;
              } catch (ignore) {
                console.log(ignore);
              }
            }

            document.getElementById("TencentCaptcha").addEventListener("click", () => {
              window.localStorage.setItem(
                key,
                JSON.stringify({ id: idEl.value, passwd: passwdEl.value })
              );
            });


            document.body.style.color = "\(SMUtils.hex(from: SMTheme.colorForPrimary()) ?? "#666")"
        """
        debugPrint(js)
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func loginSuccess() {
        if (target != nil && selector != nil) {
            target?.perform(selector)
        }
        if (self.successFunc != nil) {
            self.successFunc!()
        }
        self.close()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            self?.navigationController?.dismiss(animated: true, completion: nil)
//        }
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
