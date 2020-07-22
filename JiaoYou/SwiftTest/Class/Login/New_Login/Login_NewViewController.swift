//
//  Login_NewViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/5/28.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import JMessage

class Login_NewViewController: RJViewController {
    
    var showRegis: Bool?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layer.shadowColor = RGBAColor(34, 217, 76, 1.0).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowRadius = 10
        contentView.layer.cornerRadius = 8.0
        
        if showRegis == true {
            let story = UIStoryboard(name: "Login", bundle: nil)
            let regis = story.instantiateViewController(withIdentifier: "regisnew")
            navigationController?.pushViewController(regis, animated: false)
        }
    }
    @IBAction func regisClickAction(_ sender: Any) {
    }
    
    @IBAction func loginClickAction(_ sender: Any) {
        guard let mobile = self.mobileTextField.text, mobile.count > 0 else {
            showMessage(message: "请输入账号")
            self.mobileTextField.becomeFirstResponder()
            return
        }
        guard let pwd = self.pwdTextField.text, pwd.count > 0 else {
            showMessage(message: "请输入密码")
            self.pwdTextField.becomeFirstResponder()
            return
        }
        
        showProgressHUD()
        RJNetworking.CJNetworking().userLogin(mobile, pwd: pwd) { (response) in
            if response.code == .Success {
                let result = response.response?["info"]
                CurrentUser.sharedInstance.userId = result?["uid"].intValue ?? -1
                CurrentUser.sharedInstance.city_id = result?["city_id"].intValue ?? -1
                MobClick.profileSignIn(withPUID: "\(CurrentUser.sharedInstance.userId)")
                if let isPerfect = result?["is_perfect"].intValue, isPerfect != 1 {// 完善信息
                    self.hideProgressHUD()
                    self.navigationController?.pushViewController(PrefectInfoViewController(), animated: true)
                } else {
                    if let vip = result?["vip"].intValue {
                        
                        CurrentUser.sharedInstance.vip = vip
                        if vip == 0 {
                            self.hideProgressHUD()
                            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                            let join = storyBoard.instantiateViewController(withIdentifier: "join")
                            self.navigationController?.pushViewController(join, animated: true)
                        } else {
                            JMSGUser.login(withUsername: CurrentUser.sharedInstance.JMUserName!, password: CurrentUser.sharedInstance.JMUserPwd) { (result, error) in
                                if error == nil {
                                    CurrentUser.sharedInstance.loginJM = true
                                    let userDefault = UserDefaults.standard
                                    userDefault.set(CurrentUser.sharedInstance.userId, forKey: "uid")
                                    userDefault.set(CurrentUser.sharedInstance.city_id, forKey: "city_id")
                                    userDefault.set(CurrentUser.sharedInstance.vip, forKey: "vip")
                                    userDefault.synchronize()
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    let tabbar = RJTabBarController()
                                    appDelegate.window?.rootViewController = tabbar
                                    DispatchQueue.global().async {
                                        let num = JMSGConversation.getAllUnreadCount().intValue
                                        CurrentUser.showMessageBadge(num)
                                    }
                                    self.hideProgressHUD()
                                } else {
                                    self.hideProgressHUD(message: "登录失败")
                                }
                            }
                        }
                    } else {
                        self.hideProgressHUD()
                    }
                }
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let btn = sender as? UIButton {
            if btn.tag == 101 {
                let vc = segue.destination as! Regis_NewViewController
                vc.resetPwd = true
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
