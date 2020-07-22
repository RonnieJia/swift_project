//
//  AppDelegate.swift
//  SwiftApp
//  皮蛋 13735452873   1984JAMES
//  guxiaodong@aliyun.com     19810405James

import UIKit
import IQKeyboardManagerSwift
import JMessage

public protocol SelfAware: class {
    static func awake()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let JMAPPKEY = "1a6a430102bc9c0207848816"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds);
        self.window!.backgroundColor = .white;
        
        jchatSetting(launchOptions)
        settingIQKeyboard()
        
        UMConfigure.initWithAppkey("5ebe4d02167edd300e00013a", channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        MobClick.setCrashReportEnabled(true)
        
        let userDefault = UserDefaults.standard
        let uid = userDefault.integer(forKey: "uid")
        if uid > 0 {
            CurrentUser.sharedInstance.userId = uid
            CurrentUser.sharedInstance.city_id = userDefault.integer(forKey: "city_id")
            CurrentUser.sharedInstance.vip = userDefault.integer(forKey: "vip")
            self.window!.rootViewController = RJTabBarController()
            MobClick.profileSignIn(withPUID: "\(CurrentUser.sharedInstance.userId)")
            DispatchQueue.global().async {
                let num = JMSGConversation.getAllUnreadCount().intValue
                CurrentUser.showMessageBadge(num)
            }
        } else {
            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
            let loginEntance = storyBoard.instantiateViewController(withIdentifier: "LoginEntance");
            self.window?.rootViewController = RJNavigationController(rootViewController: loginEntance);
            /*
            if #available(iOS 13.0, *) {
                let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry2")
                self.window!.rootViewController = RJNavigationController(rootViewController: loginEntry)
            } else {
                let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry")
                self.window!.rootViewController = RJNavigationController(rootViewController: loginEntry)
            }
             */
            self.resetBadge(0)
        }
        self.window!.makeKeyAndVisible();
        return true
    }
    
    
    func jchatSetting(_ launchOptions:[UIApplication.LaunchOptionsKey: Any]?) {
        JMessage.setupJMessage(launchOptions, appKey: JMAPPKEY, channel: nil, apsForProduction: true, category: nil, messageRoaming: true)
        JMessage.add(self, with: nil)
        JMessage.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue |
        UIUserNotificationType.sound.rawValue |
        UIUserNotificationType.alert.rawValue, categories: nil)
    }
    
    func settingIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JMessage.registerDeviceToken(deviceToken)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        DispatchQueue.global().async {
            let num = JMSGConversation.getAllUnreadCount().intValue
            CurrentUser.showMessageBadge(num)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
//        DispatchQueue.global().async {
//            let num = JMSGConversation.getAllUnreadCount().intValue
//            CurrentUser.showMessageBadge(num)
//        }
//        resetBadge(application)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("didReceiveRemoteNotification")
    }
    
    private func resetBadge(_ number: Int) {
        UIApplication.shared.applicationIconBadgeNumber = number
        UIApplication.shared.cancelAllLocalNotifications()
        CurrentUser.showMessageBadge(number)
        if number == 0 {
            JMessage.resetBadge()
        } else {
            JMessage.setBadge(number)
        }
    }
}

extension AppDelegate: JMessageDelegate {
    func onDBMigrateStart() {// 数据库升级
        
    }
    
    func onDBMigrateFinishedWithError(_ error: Error!) {
        
    }
    
    /// 监听当前用户登录状态变更事件
    func onReceive(_ event: JMSGUserLoginStatusChangeEvent!) {
        switch event.eventType.rawValue {
        case JMSGLoginStatusChangeEventType.eventNotificationLoginKicked.rawValue,
        JMSGLoginStatusChangeEventType.eventNotificationServerAlterPassword.rawValue,
        JMSGLoginStatusChangeEventType.eventNotificationUserLoginStatusUnexpected.rawValue:
            let userDefault = UserDefaults.standard
            userDefault.removeObject(forKey: "uid")
            userDefault.synchronize()
            CurrentUser.sharedInstance.userId = -1
            CurrentUser.sharedInstance.loginJM = false
            MobClick.profileSignOff()
            let alert = UIAlertController(title: "提示", message: "您的账号在别处登录，若不是您本人操作，请尽快修改密码~", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let login = storyBoard.instantiateViewController(withIdentifier: "LoginEntance") as! LoginEntanceViewController
                self.window?.rootViewController = RJNavigationController(rootViewController: login)
                /*
                if #available(iOS 13.0, *) {
                    let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry2")
                    self.window!.rootViewController = RJNavigationController(rootViewController: loginEntry)
                } else {
                    let loginEntry = storyBoard.instantiateViewController(withIdentifier: "LoginEntry")
                    self.window!.rootViewController = RJNavigationController(rootViewController: loginEntry)
                }
 */
            }))
            JMSGUser.logout(nil)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        DispatchQueue.global().async {
            let num = JMSGConversation.getAllUnreadCount().intValue
            CurrentUser.showMessageBadge(num)
        }
    }
    
    func onConversationChanged(_ conversation: JMSGConversation!) {
        DispatchQueue.global().async {
            let num = JMSGConversation.getAllUnreadCount().intValue
            CurrentUser.showMessageBadge(num)
        }
    }
}




