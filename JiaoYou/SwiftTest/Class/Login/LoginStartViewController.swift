//
//  LoginStartViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/5/6.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import AuthenticationServices
import JMessage

class LoginStartViewController: RJViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var regisBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var vistorBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        regisBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        vistorBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        appleBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        view.backgroundColor = .black
        if view.width < 375 {
            self.imgView.contentMode = .scaleAspectFill
        } else {
            self.imgView.contentMode = .scaleAspectFit
        }
    }
    
    @IBAction func itemTouchDown(_ sender: UIButton) {
        sender.backgroundColor = .lightGray
    }
    
    @IBAction func itemTouchUpInside(_ sender: UIButton) {
        if sender.tag == 102 {
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = .white
        }
        
        if sender.tag == 103 {
            if #available(iOS 13.0, *) {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                let auth = ASAuthorizationController(authorizationRequests: [request])
                auth.delegate = self
                auth.presentationContextProvider = self
                auth.performRequests()
            }
        }
    }
    
    @IBAction func itemTouchUpOutside(_ sender: UIButton) {
        if sender.tag == 102 {
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = .white
        }
    }
    
    @objc func cancelButtonHighlight(_ sender: UIButton) {
        sender.isHighlighted = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     @IBAction func itemTouchDown(_ sender: UIButton) {
     }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
@available(iOS 13.0, *)
extension LoginStartViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let apple = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = apple.user
//            let email = apple.email
//            let identityToken = apple.identityToken
//            let fullName = apple.fullName
            self.loginWithApple(userIdentifier)
        } else if let pass = authorization.credential as? ASPasswordCredential {
//            let username = pass.user
//            let pwd = pass.password
        }
    }
    
    func loginWithApple(_ userId: String) {
        showProgressHUD()
        RJNetworking.CJNetworking().appleLogin(userId) { (response) in
            if response.code == .Success {
                let result = response.response?["info"]
                CurrentUser.sharedInstance.userId = result?["uid"].intValue ?? -1
                CurrentUser.sharedInstance.city_id = result?["city_id"].intValue ?? -1
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
                                    let userDefault = UserDefaults.standard
                                    userDefault.set(CurrentUser.sharedInstance.userId, forKey: "uid")
                                    userDefault.set(CurrentUser.sharedInstance.city_id, forKey: "city_id")
                                    userDefault.set(CurrentUser.sharedInstance.vip, forKey: "vip")
                                    userDefault.synchronize()
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = RJTabBarController()
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
    
    
}


