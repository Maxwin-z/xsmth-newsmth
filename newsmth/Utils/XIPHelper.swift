//
//  XIPHelper.swift
//  newsmth
//
//  Created by WenDong on 2020/7/4.
//  Copyright © 2020 nju. All rights reserved.
//

import Foundation

struct XIPInfo: Codable {
    var country: String
    var province: String
    var city: String
    var ISP: String
}

class XIPHelper {
    static let shared = XIPHelper()
    
    var entry: ip2region_entry = ip2region_entry()
    private var hasDB = false
    
    private init() {
        loadDB()
    }
    
    private func loadDB() {
        let dbFile =  "/remoteresource/ip2region"
        if (SMUtils.fileExists(inDocumentFolder: dbFile)) {
            ip2region_create(&entry, SMUtils.documentPath() + dbFile)
            hasDB = true
        }
    }
    
    private func info2json(info: XIPInfo) -> [String: String] {
        return [
            "country": info.country,
            "province": info.province,
            "city": info.city,
            "ISP": info.ISP
        ]
    }

    func query(ip: String) -> [String: String] {
        if (!hasDB) {
            loadDB()
        }
        if (!hasDB) {
            return info2json(info: XIPInfo(country: "", province: "", city: "", ISP: ""))
        }
        var result: datablock_entry = datablock_entry()
        ip2region_memory_search_string(&entry, ip, &result)
        let info = withUnsafePointer(to: result.region) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: result.region)) {
                String(cString: $0)
            }
        }
        let comps = info.components(separatedBy: "|")
        return info2json(info: XIPInfo(country: comps[0], province: comps[2], city: comps[3], ISP: comps[4]))
    }
}
