//
//  LoginViewController.swift
//  SwiftApp

import RJNetworking_Swift
import UIKit
import JMessage

class LoginViewController: RJViewController {

    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var loginItem: RJAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginItem.addTarget(target: self, action: #selector(userLogin), for: .touchUpInside)
    }
    

    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func agreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func agreementPush(_ sender: Any) {
        let agree = HelpGuideViewController()
        agree.type = 2
        self.navigationController?.pushViewController(agree, animated: true)
    }
    
    @objc func userLogin() {
        if !agreeBtn.isSelected {
            showMessage(message: "请阅读并同意《用户注册协议》")
            return
        }
        guard !(mobileTextField.text?.isEmpty ?? true) else {
            showMessage(message: "请输入手机号")
            return
        }
        guard !(pwdTextField.text?.isEmpty ?? true) else {
            showMessage(message: "请输入密码")
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().userLogin(mobileTextField.text!, pwd: pwdTextField.text!) { (response) in
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
                                    appDelegate.window?.rootViewController = RJTabBarController()

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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "forgetPwd" {
            let forget = segue.destination as! RegisMobileViewController
            forget.forget = true
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
