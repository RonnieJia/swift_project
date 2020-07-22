//
//  Regis_NewViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/5/28.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class Regis_NewViewController: RJViewController {

    var resetPwd: Bool = false
    
    @IBOutlet weak var agreeView: UIView!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdTextField2: UITextField!
    
    var time = 60
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.shadowColor = RGBAColor(34, 217, 76, 1.0).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowRadius = 10
        contentView.layer.cornerRadius = 8.0
        codeBtn.cancelHighlighted()
        agreeView.isHidden = resetPwd
    }
    
    @IBAction func sendMobileCode(_ sender: UIButton) {
        guard let mobile = self.mobileTextField.text, mobile.count == 11 else {
            showMessage(message: "请输入手机号")
            self.mobileTextField.becomeFirstResponder()
            return
        }
        guard !sender.isSelected else {
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().fetchCode(mobile, type: resetPwd ? 2 : 1) { [unowned self] response in
            if response.code == Code.Success {
                self.startTime()
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    @IBAction func sureClickAction(_ sender: UIButton) {
        guard self.agreeBtn.isSelected else {
            showMessage(message: "请阅读并同意《用户注册协议》")
            return
        }
        guard let mobile = self.mobileTextField.text, mobile.count == 11 else {
            showMessage(message: "请输入手机号")
            self.mobileTextField.becomeFirstResponder()
            return
        }
        guard let code = self.codeTextField.text, code.count > 0 else {
            showMessage(message: "请输入验证码")
            self.codeTextField.becomeFirstResponder()
            return
        }
        guard let pwd = self.pwdTextField.text, pwd.count > 0 else {
            showMessage(message: "请输入密码")
            self.pwdTextField.becomeFirstResponder()
            return
        }
        guard let pwd2 = self.pwdTextField2.text, pwd2.count > 0 else {
            showMessage(message: "请确认密码")
            self.pwdTextField2.becomeFirstResponder()
            return
        }
        guard pwd == pwd2 else {
            showMessage(message: "两次密码不一致")
            return
        }
        showProgressHUD()
        if resetPwd {
            RJNetworking.CJNetworking().forgetPwd(mobile, pwd: pwd, code: code) { (response) in
                if response.code == Code.Success {
                    if let viewcontrollers = self.navigationController?.viewControllers {
                        for vc in viewcontrollers {
                            if vc.isKind(of: Login_NewViewController.self) {
                                self.navigationController?.popToViewController(vc, animated: true)
                                break
                            }
                        }
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.hideProgressHUD()
                } else {
                    self.hideProgressHUD(message: response.message)
                }
            }
        } else {
            RJNetworking.CJNetworking().regis(mobile, pwd: pwd, code: code) { (response) in
                if response.code == Code.Success {
                    CurrentUser.sharedInstance.userId = response.response?["uid"].intValue ?? -1
                    self.navigationController?.pushViewController(PrefectInfoViewController(), animated: true)
                    self.hideProgressHUD()
                } else {
                    self.hideProgressHUD(message: response.message)
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pushAgreeMent(_ sender: UIButton) {
        let agree = HelpGuideViewController()
        agree.type = 2
        self.navigationController?.pushViewController(agree, animated: true)
    }
    
    @IBAction func agreeClickActopm(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    private func startTime() {
        invalidateTimer()
        time = 60
        codeBtn.isSelected = true
        codeBtn.setTitle("(\(time)s)", for: .selected)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeCodeBtnTimeTitle), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        timer?.fire()
    }
    
    @objc private func changeCodeBtnTimeTitle() {
        time -= 1
        if time == 0 {
            codeBtn.isSelected = false
            invalidateTimer()
            return
        }
        codeBtn.setTitle("(\(time)s)", for: .selected)
    }
    
    private func invalidateTimer() {
        if timer != nil {
            if timer?.isValid ?? false {
                timer?.invalidate()
            }
            timer = nil
        }
    }
    
    deinit {
        invalidateTimer()
    }
    
}
