//
//  SMURLProtocol.swift
//  newsmth
//
//  Created by Max on 2020/2/13.
//  Copyright © 2020 nju. All rights reserved.
//

import Alamofire
import Foundation
import WebKit
import Combine

extension String {
    init?(gbkData: Data) {
        //获取GBK编码, 使用GB18030是因为它向下兼容GBK
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        //从GBK编码的Data里初始化NSString, 返回的NSString是UTF-16编码
        if let str = NSString(data: gbkData, encoding: encoding) {
            self = str as String
        } else {
            return nil
        }
    }
    
    var gbkData: Data {
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        let gbkData = (self as NSString).data(using: encoding)!
        return gbkData
    }
    
}

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

struct XParseError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}


@objcMembers
class SMSession: NSObject {
    static let shared = SMSession()
    var session: Session
    var webView: WKWebView!
    var keep: AnyCancellable?;
    
    override init() {
        let monitor = ClosureEventMonitor()
        monitor.requestDidFinish = { request in
            if let headers = request.response?.headers {
                if let cookies = headers.value(for: "Set-Cookie") {
                    if cookies.contains("main[UTMPUSERID]") {
                        SMAccountManager.instance()?.refreshStatus()
                    }
                }
            }
        }
        session = Session(eventMonitors: [monitor])
        
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: config)
    }
    
    @objc
    func loadUrl_oc(_ parser: String,
                    url: URL,
                    method: String,
                    success: @escaping(Any) -> Void,
                 parameters: Parameters? = nil,
                 headers: [String: String]? = nil) {
        var _headers = HTTPHeaders()
        headers?.forEach({ (key: String, value: String) in
            _headers.add(name: key, value: value)
        })
        self.keep = self.loadUrl(parser, convertible: url, method: method == "GET" ? .get : .post, headers: _headers)
            .sink { _ in
            } receiveValue: { data in
                success(data)
                self.keep = nil
            }
    }
    
    @objc
    func loadJSON(_ url: URL, method: String, success: @escaping(NSDictionary?) -> Void, parameters: Parameters? = nil, headers: [String: String]? = nil) {
        var _headers = HTTPHeaders()
        headers?.forEach({ (key: String, value: String) in
            _headers.add(name: key, value: value)
        })
        _headers.add(name: "content-type", value: "application/x-www-form-urlencoded; charset=UTF-8")
        self.session.request(url,
                             method: method == "GET" ? .get : .post,
                             parameters: parameters,
                             headers: _headers
        )
        .response { response in
            do {
                if let data = try response.result.get() {
                    if let text = String(gbkData: data) {
                        let jsonData = text.data(using: .utf8)
                        if let json = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? NSDictionary {
                            success(json)
                        }
                    }
                }
            } catch {
                success(nil)
            }
        }
//        .responseString(completionHandler: { html in
//            print(html)
//        })
//        .responseJSON { response in
//            print(response)
//            switch response.result {
//            case .success:
//                let data = response.value as! NSDictionary;
//                success(data)
//            case .failure(let error):
//                print(error)
//                break
//            }
//        }
        
    }
    
    
    func loadUrl(_ parser: String, convertible: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoder: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil,
                 interceptor: RequestInterceptor? = nil,
                 requestModifier: Session.RequestModifier? = nil) -> Future<SMBaseData, XParseError> {
        return Future { promise in
            let files = parser.components(separatedBy: ",")
            var js = ""
            for f in files {
                js += self.loadJS(f) ?? ""
            }
//            debugPrint(js)
            
            if (js.isEmpty) {
                promise(.failure(XParseError("解析器不存在")))
                return
            }
            self.session.request(convertible,
                                method: method,
                                parameters: parameters,
    //                            encoder: encoder, ?? error here
                                headers: headers,
                                interceptor: interceptor,
                                requestModifier: requestModifier).response { response in
               do {
                   if let data = try response.result.get() {
                       var html = String(data: data, encoding: .utf8)
                       if (html == nil) {
                           promise(.failure(XParseError("网页内容加载失败")))
                           return
                       }
                       html = html!.replacingOccurrences(of: "`", with: "\\`")
                       self.webView.evaluateJavaScript("\(js);$smth={sendData:_=>_};$parse(`\(html ?? "")`)") { result, error in
//                           debugPrint(error ?? "no error")
//                           debugPrint("result", result)
                           if let json = result as? Dictionary<String, Any> {
//                               debugPrint(json["data"])
                               if let data = json["data"] as? Dictionary<String, Any> {
                                   if let model = SMBaseData(json2: data) {
                                       promise(.success(model))
                                   } else {
                                       promise(.failure(XParseError("生成数据错误")))
                                   }
                               } else {
                                   promise(.failure(XParseError("解析器返回异常")))
                               }
                           }
                       }
                   }
               } catch {
                   promise(.failure(XParseError("解析网页内容异常")))
               }
            }
        }
        
    }
    
    func loadJS(_ filename: String) -> String? {
            var data = SMUtils.readData(fromDocumentFolder: "parser/\(filename)")
            if (data == nil) {
                if let url = Bundle.main.url(forResource: filename, withExtension: "js") {
                    do {
                        data = try Data(contentsOf: url)
                        if (data != nil) {
                            return String(data: data!, encoding: .utf8)
                        }
                    } catch {}
                } else {
                    return nil
                }
            }
        return nil
//        - (NSString *)loadJS:(NSString *)filename
//        {
//            NSData *data = [SMUtils readDataFromDocumentFolder:[NSString stringWithFormat:@"parser/%@.js", filename]];
//
//            if (data == nil) {
//                NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"js"];
//                if (!filePath) return @"";
//                data = [NSData dataWithContentsOfFile:filePath];
//            }
//
//            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        }
    }
}

let SMAF = SMSession.shared.session

