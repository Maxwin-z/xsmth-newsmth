//
//  SMURLProtocol.swift
//  newsmth
//
//  Created by Max on 2020/2/13.
//  Copyright © 2020 nju. All rights reserved.
//

import Foundation
import Alamofire

final class SMURLProtocol : URLProtocol {

    override public class func canInit(with request: URLRequest) -> Bool {
        // Print valuable request information.
        print("? Running request: \(request.httpMethod ?? "") - \(request.url?.absoluteString ?? "")")

        // By returning `false`, this URLProtocol will do nothing less than logging.
        return false
    }
    
    @objc
    public static func doRegister() {
        URLProtocol.registerClass(SMURLProtocol.self)
        
        let session = Alamofire.Session.default
        if var classes = session.sessionConfiguration.protocolClasses {
            classes.insert(SMURLProtocol.self, at: 0)
        } else {
            session.sessionConfiguration.protocolClasses = [SMURLProtocol.self]
        }
    }
}


class SMSession : NSObject {
    static let shared = SMSession()
    var session: Session
    override init() {
        let monitor = ClosureEventMonitor()
        monitor.requestDidFinish = { request in
            debugPrint("31", request.response?.headers ?? "header is nil")
        }
        self.session = Session(eventMonitors: [monitor])
    }
}

let SMAF = SMSession.shared.session
