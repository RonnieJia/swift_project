//
//  UIViewController+extension.swift
//  SwiftApp
//
//  Created by jia on 2020/4/14.
//  Copyright © 2020 RJ. All rights reserved.
//
import UIKit
import MBProgressHUD
import NVActivityIndicatorView


public extension UIViewController {
    func showAlert(title t: String?, message m: String?, buttonTitle bt: String? = "确定") {
        if (t == nil || t!.isEmpty) && (m == nil || m!.isEmpty) {// 没有提示文案
            return
        }
        let alert = UIAlertController(title: t, message: m, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: bt, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessage(message: String) {
        self.view.showMessage(message: message)
    }
    
    func showProgressHUD(type:NVActivityIndicatorType? = NVActivityIndicatorView.DEFAULT_TYPE, message: String? = nil) {
        self.view.showProgressHUD(type: type, message: message)
    }
    
    func hideProgressHUD(message: String? = nil)  {
        self.view.hideProgressHUD(message: message)
    }
    
    
    func showLoginAlert() {
        LoginAlertView.show { (type) in
            if type < 2 {
                let story = UIStoryboard(name: "Login", bundle: nil)
                let login = story.instantiateViewController(withIdentifier: "loginnew") as! Login_NewViewController
                if type == 0 {
                    self.navigationController?.pushViewController(login, animated: true)
                } else if type == 1 {
                    login.showRegis = true
                    self.navigationController?.pushViewController(login, animated: true)
                }
            }
        }
    }
}


