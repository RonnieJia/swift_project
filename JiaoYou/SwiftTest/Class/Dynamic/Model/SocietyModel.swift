//
//  SocietyModel.swift
//  SwiftApp
//
//  Created by jia on 2020/4/27.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import SwiftyJSON
/// 评论
struct CommentModel {
    var add_time: TimeInterval
    var avatarUrl: String
    var comment_id: Int
    var content: String
    var nickname: String
    var show_id: Int
    var user_id: Int
    
    static func model(item: JSON) -> CommentModel? {
        let m = CommentModel(add_time: item["add_time"].doubleValue,
                             avatarUrl: item["avatarUrl"].stringValue,
                             comment_id: item["comment_id"].intValue,
                             content: item["content"].stringValue,
                             nickname: item["nickname"].stringValue,
                             show_id: item["show_id"].intValue,
                             user_id: item["user_id"].intValue)
        return m
    }
    
    static func listArr(list: JSON?) -> [CommentModel] {
        guard list != nil else { return [] }
        var newArr = [CommentModel]()
        if let arr = list!.array {
            for item in arr {
                if let m = CommentModel.model(item: item) {
                    newArr.append(m)
                }
            }
        }
        return newArr
    }
}


struct SocietyModel {
    var show_id: Int
    var user_id: Int
    var like_num: Int
    var com_num: Int
    var state: Int
    var age: Int
    var vip: Int
    var sex: Int
    var follow: Int
    var nickname: String
    var avatarUrl: String
    var constellation: String
    var show_img: [String]
    var times: Int
    var like: Int
    
    
    static func model(item: JSON) -> SocietyModel? {
        var showImgs = [String]()
        if let imgs = item["show_img"].arrayObject as? [String] {
            showImgs = imgs
        }
        let m = SocietyModel(show_id: item["show_id"].intValue,
                             user_id: item["user_id"].intValue,
                             like_num: item["like_num"].intValue,
                             com_num: item["com_num"].intValue,
                             state: item["state"].intValue,
                             age: item["age"].intValue,
                             vip: item["vip"].intValue,
                             sex: item["sex"].intValue,
                             follow: item["follow"].intValue,
                             nickname: item["nickname"].stringValue,
                             avatarUrl: item["avatarUrl"].stringValue,
                             constellation: item["constellation"].stringValue,
                             show_img: showImgs,
                             times: item["times"].intValue,
                             like: item["like"].intValue)
        return m
    }
    
    static func listArr(list: JSON?) -> [SocietyModel] {
        guard list != nil else { return [] }
        var newArr = [SocietyModel]()
        if let arr = list!.array {
            for item in arr {
                if let m = SocietyModel.model(item: item) {
                    newArr.append(m)
                }
            }
        }
        return newArr
    }
}
