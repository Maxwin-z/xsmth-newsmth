//
//  XRemoteResourceManager.swift
//  newsmth
//
//  Created by WenDong on 2020/6/26.
//  Copyright © 2020 nju. All rights reserved.
//

import Foundation
import Alamofire
import CryptoKit


struct XRRMConfig {
    var url: String
}
struct XRRMItem: Codable {
    var url: String
    var md5: String
    var key: String
}
struct XRRMList: Codable {
    var items: [XRRMItem]
}

@objc
class XRemoteResourceManager: NSObject {
    var config: XRRMConfig;
    override init() {
        self.config = XRRMConfig(url: "https://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/resourceconfig.json")
    }
    init(config: XRRMConfig) {
        self.config = config
    }
    
    @objc
    public func start() {
        if let url = URL(string: config.url) {
            AF.request(url).responseData { response in
                do {
                    let list = try JSONDecoder().decode(XRRMList.self, from: response.value!)
                    list.items.forEach { item in
                        debugPrint(item)
                        let resourceUrl = item.url
                        let md5 = item.md5
                        let key = item.key
                        let filepath = "remoteresource/\(key)"
                        if (SMUtils.fileExists(inDocumentFolder: filepath)) {
                            if let file = SMUtils.readData(fromDocumentFolder: filepath) {
                                let fileMd5 = self.data2md5(data: file)
                                if (fileMd5 == md5) {
                                    debugPrint("\(filepath) exists with md5(\(md5))")
                                    return
                                }
                            }
                            
                        }
                        AF.download(URL(string: resourceUrl)!).responseData { response in
                            if let data = response.value {
                                let dataMd5 = self.data2md5(data: data)
                                debugPrint(md5, dataMd5)
                                if (dataMd5 == md5) {
//                                    try? data.write(to: filename)
                                    SMUtils.write(data, toDocumentFolder: filepath)
                                    debugPrint("download \(item) success to \(filepath)")
                                }
                            }
                        }
                    }
                } catch {
                    debugPrint("XRRM ERROR:\(error)")
                }
            }
        }
//        debugPrint(XIPHelper.shared.query(ip: "13.91.210.8"))
    }
    
    func data2md5(data: Data) -> String {
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0)}.joined()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }}
