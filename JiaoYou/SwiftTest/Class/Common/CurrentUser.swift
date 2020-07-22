//
//  CurrentUser.swift
//  SwiftApp

import UIKit
import SwiftyJSON
import JMessage

class CurrentUser: NSObject {
    enum UserSex {
        case boy
        case girl
    }
    
    var userId: NSInteger = -1
    var city_id: NSInteger = -1
    var userSex: UserSex = .boy
    var vip: Int = 0
    var loginJM: Bool = false
    
    var nickname: String?
    var address: String?
    var age: Int = 0
    var height: Int = 0
    var avatarUrl: String?
    var birthday: String?
    var city: String?
    var constellation: String?
    var self_info: String?
    var occupation: String?
    
    var JMUserName: String? {
        get {
            if userId > 0 {
                return "real\(userId)"
            }
            return nil
        }
        set {
            
        }
    }
    
    let JMUserPwd = "123456"
    
    func userInfo(_ info: JSON?) {
        guard info != nil else {
            return
        }
        self.nickname = info!["nickname"].stringValue
        self.address = info!["address"].stringValue
        self.age = info!["age"].intValue
        self.height = info!["height"].intValue
        self.avatarUrl = info!["avatarUrl"].stringValue
        self.userSex = info!["sex"].intValue == 1 ? .boy : .girl
        let bir = info!["birthday"].doubleValue
        let date = Date(timeIntervalSince1970: bir)
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        self.birthday = format.string(from: date)
        self.city = info!["city"].stringValue
        self.constellation = info!["constellation"].stringValue
        self.self_info = info!["self_info"].stringValue
        self.vip = info!["vip"].intValue
        self.occupation = info!["occupation"].stringValue
    }
    
    static let sharedInstance = CurrentUser()
    
    static func isVisitor() -> Bool {
        let user = CurrentUser.sharedInstance
        return user.userId <= 0
    }
    
    static func showMessageBadge(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
            if count == 0 {
                JMessage.resetBadge()
            } else {
                JMessage.setBadge(count)
            }
            
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                if let tabbar = appdelegate.window?.rootViewController as? RJTabBarController {
                    tabbar.showMessageBadge(count)
                }
            }
        }
    }
    
    static func blackUser(_ jmUid: String, dele: Bool) {
        if dele {
            // 拉黑好友
            JMSGUser.delUsers(fromBlacklist: [jmUid]) { (_, error) in
                if error != nil {
                    NSLog("移除黑名单失败")
                }
            }
            return
        }
        // 拉黑好友
        JMSGUser.addUsers(toBlacklist: [jmUid]) { (_, error) in
            if error != nil {
                NSLog("加入黑名单失败")
            }
        }
        JMSGConversation.deleteSingleConversation(withUsername: jmUid)
    }
}
