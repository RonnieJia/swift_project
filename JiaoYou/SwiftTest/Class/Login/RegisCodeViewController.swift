//
//  RegisCodeViewController.swift
//  SwiftApp

import UIKit
import RJNetworking_Swift

class RegisCodeViewController: RJViewController, RJCodeViewDelegate {

    var mobile: String?
    var forget: Bool = false
    
    var fetchCode: Int?
    
    @IBOutlet weak var codeView: RJCodeView!
    @IBOutlet weak var mobielLabel: UILabel!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var nextItem: RJAnimationView!
    var time = 60
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeView.delegate = self
        if var str = mobile, str.count == 11 {
            str.insert(" ", at: str.index(str.startIndex, offsetBy: 7))
            str.insert(" ", at: str.index(str.startIndex, offsetBy: 3))
            mobielLabel.text = str
        } else {
            mobielLabel.text = nil
        }
        nextItem.addTarget(target: self, action: #selector(setPassword), for: .touchUpInside)
        codeView.textField.becomeFirstResponder()
        startTime()
    }
    
    func requestCode() {
        showProgressHUD()
        RJNetworking.CJNetworking().fetchCode(self.mobile!, type: forget ? 2 : 1) { response in
            if response.code == Code.Success {
                self.fetchCode = response.response?["code"].intValue
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    func startTime() {
        invalidateTimer()
        time = 60
        codeBtn.isSelected = true
        codeBtn.setTitle("(\(time)s)", for: .selected)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeCodeBtnTimeTitle), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func changeCodeBtnTimeTitle() {
        time -= 1
        if time == 0 {
            codeBtn.isSelected = false
            invalidateTimer()
            return
        }
        codeBtn.setTitle("(\(time)s)", for: .selected)
    }
    
    @objc func setPassword() {
        if (self.fetchCode ?? 0) > 0 {
            if "\(self.fetchCode!)" == self.codeView.textField.text! {
                let pwd = self.storyboard?.instantiateViewController(withIdentifier: "pwd") as! RegisPwdViewController
                pwd.forget = self.forget
                pwd.phone = self.mobile
                pwd.code = self.codeView.textField.text
                self.navigationController?.pushViewController(pwd, animated: true)
            } else {
                self.showMessage(message: "验证码错误，请重新输入")
            }
        } else {
            let pwd = self.storyboard?.instantiateViewController(withIdentifier: "pwd") as! RegisPwdViewController
            pwd.forget = self.forget
            pwd.phone = self.mobile
            pwd.code = self.codeView.textField.text
            self.navigationController?.pushViewController(pwd, animated: true)
        }
    }

    func codeCompletion(enable: Bool) {
        nextItem.isEnable = enable
    }
    
    @IBAction func fetchCode(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        requestCode()
        startTime()
    }
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func invalidateTimer() {
        if timer != nil {
            if timer?.isValid ?? false {
                timer?.invalidate()
            }
            timer = nil
        }
    }
}
