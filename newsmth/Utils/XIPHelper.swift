//
//  XIPHelper.swift
//  newsmth
//
//  Created by WenDong on 2020/7/4.
//  Copyright © 2020 nju. All rights reserved.
//

import Foundation

struct XIPInfo {
    var country: String
    var province: String
    var city: String
    var ISP: String
}

class XIPHelper {
    static let shared = XIPHelper()
    
    var entry: ip2region_entry = ip2region_entry()
    
    private init() {
        let dbFile = SMUtils.documentPath() + "/remoteresource/ip2region"
        ip2region_create(&entry, dbFile)
   }
    
    func query(ip: String) -> XIPInfo {
        var result: datablock_entry = datablock_entry()
        ip2region_memory_search_string(&entry, ip, &result)
        let info = withUnsafePointer(to: result.region) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: result.region)) {
                String(cString: $0)
            }
        }
        let comps = info.components(separatedBy: "|")
        return XIPInfo(country: comps[0], province: comps[2], city: comps[3], ISP: comps[4])
    }
}
