//
//  HomeModel.swift
//  SwiftApp
//
//  Created by jia on 2020/3/20.
//  Copyright © 2020 RJ. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UserShow {
    var show_id: Int
    var show_img: [String]
    
    static func showListArr(list: JSON?) -> [UserShow] {
        guard list != nil else { return [] }
        var newArr = [UserShow]()
        if let arr = list!.arrayObject as? [[String: Any]] {
            for item in arr {
                if let showid = item["show_id"] as? Int {
                    let imgs = item["show_img"]
                    let m = UserShow(show_id: showid,
                                     show_img: imgs as! [String])
                    newArr.append(m)
                }
            }
        }
        return newArr
    }
}

public struct HomeModel {
    var city: String?
    var self_info: String?
    var user_id: Int?
    var avatarUrl: String?
    var nickname: String?
    var constellation: String?
    var vip: Int? // vip值>1为付费会员，vip=1为普通用户
    var sex: Int?
    var follow: Int? //是否关注，1=已关注，2=未关注
    var state: Int?// 身份是否认证，1=未认证，2=认证中，3已认证
    var video_state: Int?// 视频是否认证，1=未认证，2=认证中，3已认证
    var age: Int?
    var height: Int?
    var shows: [UserShow]
    var type: Int?// 用户类型，1=真实用户，2=马家用户
    var province: String?
    var video: String?
    
    var jmuserName: String {
        get {
            if self.type == 1 {
                return "real\(self.user_id!)"
            } else {
                return "fictitious\(self.user_id!)"
            }
        }
        set {
            
        }
    }
    
    static func homeModel(result: JSON?) -> HomeModel? {
        guard result != nil else { return nil }
        if let item = result!["users"].dictionaryObject {
            var showArr: [UserShow] = []
            if let shows =  result?["shows"] {
                showArr = UserShow.showListArr(list: shows)
            }
            let m = HomeModel(city: item["city"] as? String,
                              self_info: item["self_info"] as? String,
                              user_id: item["user_id"] as? Int,
                              avatarUrl: item["avatarUrl"] as? String,
                              nickname: item["nickname"] as? String,
                              constellation: item["constellation"] as? String,
                              vip: item["vip"] as? Int,
                              sex: item["sex"] as? Int,
                              follow: item["follow"] as? Int,
                              state: item["state"] as? Int,
                              video_state: item["video_state"] as? Int,
                              age: item["age"] as? Int,
                              height: item["height"] as? Int,
                              shows: showArr,
                              type: item["type"] as? Int,
                              province: item["province"] as? String,
                              video: item["video"] as? String)
            return m
        }
        return nil
    }
    
    static func homeListArr(list: JSON?) -> [HomeModel]? {
        guard list != nil else { return nil }
        var newArr = [HomeModel]()
        if let arr = list!.arrayObject as? [[String: Any]] {
            for item in arr {
                let m = HomeModel(city: item["city"] as? String,
                                  self_info: item["self_info"] as? String,
                                  user_id: item["user_id"] as? Int,
                                  avatarUrl: item["avatarUrl"] as? String,
                                  nickname: item["nickname"] as? String,
                                  constellation: item["constellation"] as? String,
                                  vip: item["vip"] as? Int,
                                  sex: item["sex"] as? Int,
                                  follow: item["follow"] as? Int,
                                  state: item["state"] as? Int,
                                  video_state: item["video_state"] as? Int,
                                  age: item["age"] as? Int,
                                  height: item["height"] as? Int,
                                  shows: [],
                                  type: item["type"] as? Int,
                                  video: item["video"] as? String)
                newArr.append(m)
            }
        }
        return newArr
    }
}




struct ItemModel {
    var zhuti: String?
    var down: String?
    var weburl: String?
    var bofang: String?
    
    
    static func ItemListArr(list: [[String: String]]) -> [ItemModel]? {
        guard !list.isEmpty else { return nil }
        var newArr = [ItemModel]()
        for item in list {
            let m = ItemModel(zhuti: item["zhuti"], down: item["down"], weburl: item["weburl"], bofang: item["bofang"])
            newArr.append(m)
        }
        return newArr
    }
}

public struct HomeList {
    var id: String?
    var title: String?
    var zhuyan: String?
    var daoyan: String?
    var jianjie: String?
    var playtime: String?
    var zhuti: String?
    var img: String?
    
    var items: [ItemModel]?
    
    static func homeListArr(list: [[String: String]]) -> [HomeList]? {
        guard !list.isEmpty else { return nil }
        var newArr = [HomeList]()
        for item in list {
            let m = HomeList(id: item["id"],
                             title: item["title"],
                             zhuyan: item["zhuyan"],
                             daoyan: item["daoyan"],
                             jianjie: item["jianjie"],
                             playtime: item["playtime"],
                             zhuti: item["zhuti"],
                             img: item["img"], items: nil)
            newArr.append(m)
        }
        return newArr
    }
}


