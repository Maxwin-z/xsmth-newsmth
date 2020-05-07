//
//  SMURLProtocol.swift
//  newsmth
//
//  Created by Max on 2020/2/13.
//  Copyright © 2020 nju. All rights reserved.
//

import Alamofire
import Foundation

final class SMURLProtocol: URLProtocol {
    public override class func canInit(with request: URLRequest) -> Bool {
        // Print valuable request information.
        print("? Running request: \(request.httpMethod ?? "") - \(request.url?.absoluteString ?? "")")

        // By returning `false`, this URLProtocol will do nothing less than logging.
        return false
    }

    @objc
    public static func doRegister() {
//        URLProtocol.registerClass(SMURLProtocol.self)
    }
}

class SMSession: NSObject {
    static let shared = SMSession()
    var session: Session
    override init() {
        let monitor = ClosureEventMonitor()
        monitor.requestDidFinish = { request in
            if let headers = request.response?.headers {
                if let cookies = headers.value(for: "Set-Cookie") {
                    debugPrint("4444444", cookies)
                    if cookies.contains("main[UTMPUSERID]") {
                        debugPrint("454545, login status changed")
                        SMAccountManager.instance()?.refreshStatus()
                    }
                }
            }
        }
        session = Session(eventMonitors: [monitor])
    }
}

let SMAF = SMSession.shared.session
