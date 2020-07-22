//
//  VistorModel.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/5.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import SwiftyJSON

struct VistorModel {
    var fuser_id: Int
    var sex: Int
    var user_id: Int
    var add_time: Double
    var avatarUrl: String
    var nickname: String
    
    static func model(item: JSON) -> VistorModel? {
        let m = VistorModel(fuser_id: item["fuser_id"].intValue,
                             sex: item["sex"].intValue,
                             user_id: item["user_id"].intValue,
                             add_time: item["add_time"].doubleValue,
                             avatarUrl: item["avatarUrl"].stringValue,
                             nickname: item["nickname"].stringValue)
        return m
    }
    
    static func listArr(list: JSON?) -> [VistorModel] {
        guard list != nil else { return [] }
        var newArr = [VistorModel]()
        if let arr = list!.array {
            for item in arr {
                if let m = VistorModel.model(item: item) {
                    newArr.append(m)
                }
            }
        }
        return newArr
    }
    
}



struct BlackModel {
    var fuser_id: Int
    var sex: Int
    var user_id: Int
    var add_time: Double
    var avatarUrl: String
    var nickname: String
    var u_type: Int
    
    var jmUserName: String {
        get {
            if self.u_type == 1 {
                return "real\(self.fuser_id)"
            } else {
                return "fictitious\(self.fuser_id)"
            }
        }
        set {
            
        }
    }
    
    static func model(item: JSON) -> BlackModel? {
        let m = BlackModel(fuser_id: item["fuser_id"].intValue,
                             sex: item["sex"].intValue,
                             user_id: item["user_id"].intValue,
                             add_time: item["add_time"].doubleValue,
                             avatarUrl: item["avatarUrl"].stringValue,
                             nickname: item["nickname"].stringValue,
                             u_type: item["u_type"].intValue)
        return m
    }
    
    static func listArr(list: JSON?) -> [BlackModel] {
        guard list != nil else { return [] }
        var newArr = [BlackModel]()
        if let arr = list!.array {
            for item in arr {
                if let m = BlackModel.model(item: item) {
                    newArr.append(m)
                }
            }
        }
        return newArr
    }
    
}

