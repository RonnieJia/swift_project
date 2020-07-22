//
//  VipManager.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/5.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class VipManager: NSObject {
    
    lazy var todayChatList: [Int] = []
    lazy var commentList: [Int] = []
    lazy var nearbyListList: [Int] = []
    
    func homeCanChat(_ uid: Int) -> Bool {
        if CurrentUser.isVisitor() {
            return false
        }
        if CurrentUser.sharedInstance.vip >= 2 {
            return true
        } else {
            if self.todayChatList.contains(uid) {
                return true
            } else {
                if self.todayChatList.count >= 2 {
                    return false
                } else {
                    self.todayChatList.append(uid)
                    saveHomeChatUser()
                    return true
                }
            }
        }
    }
    
    func userComment(_ uid: Int) -> Bool {
        if CurrentUser.isVisitor() {
            return false
        }
        if CurrentUser.sharedInstance.vip >= 2 {
            return true
        } else {
            if self.commentList.contains(uid) {
                return true
            } else {
                if self.commentList.count >= 2 {
                    return false
                } else {
                    self.commentList.append(uid)
                    saveCommentUser()
                    return true
                }
            }
        }
    }
    
    
    func nearbyCanChat(_ uid: Int) -> Bool {
        if CurrentUser.isVisitor() {
            return false
        }
        if CurrentUser.sharedInstance.vip == 2 {
            return true
        } else {
            if self.nearbyListList.contains(uid) {
                return true
            } else {
                if self.nearbyListList.count >= 2 {
                    return false
                } else {
                    self.nearbyListList.append(uid)
                    saveHomeChatUser()
                    return true
                }
            }
        }
    }
    
    override init() {
        super.init()
        if let dic = UserDefaults.standard.object(forKey: "\(CurrentUser.sharedInstance.userId)_homeChat") as? [String: Any] {
            guard let date = dic["time"] as? String else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_homeChat")
                UserDefaults.standard.synchronize()
                return
            }
            if date == self.todayDate() {
                if let list = dic["list"] as? [Int] {
                    self.todayChatList = list
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_homeChat")
                UserDefaults.standard.synchronize()
            }
        }
        
        if let dic = UserDefaults.standard.object(forKey: "\(CurrentUser.sharedInstance.userId)_com") as? [String: Any] {
            guard let date = dic["time"] as? String else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_com")
                UserDefaults.standard.synchronize()
                return
            }
            if date == self.todayDate() {
                if let list = dic["list"] as? [Int] {
                    self.commentList = list
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_com")
                UserDefaults.standard.synchronize()
            }
        }
        
        if let dic = UserDefaults.standard.object(forKey: "\(CurrentUser.sharedInstance.userId)_nearby") as? [String: Any] {
            guard let date = dic["time"] as? String else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_nearby")
                UserDefaults.standard.synchronize()
                return
            }
            if date == self.todayDate() {
                if let list = dic["list"] as? [Int] {
                    self.nearbyListList = list
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "\(CurrentUser.sharedInstance.userId)_nearby")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func saveHomeChatUser() {
        let dic = ["list": self.todayChatList, "time": self.todayDate()] as [String : Any]
        UserDefaults.standard.set(dic, forKey: "\(CurrentUser.sharedInstance.userId)_homeChat")
        UserDefaults.standard.synchronize()
    }
    
    func saveCommentUser() {
        let dic = ["list": self.todayChatList, "time": self.todayDate()] as [String : Any]
        UserDefaults.standard.set(dic, forKey: "\(CurrentUser.sharedInstance.userId)_com")
        UserDefaults.standard.synchronize()
    }
    
    func savenNearbyChat() {
        let dic = ["list": self.todayChatList, "time": self.todayDate()] as [String : Any]
        UserDefaults.standard.set(dic, forKey: "\(CurrentUser.sharedInstance.userId)_nearby")
        UserDefaults.standard.synchronize()
    }
    
    func todayDate() -> String {
        let dateFor = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd"
        return dateFor.string(from: Date())
    }
    
    static let shared = VipManager()
}
