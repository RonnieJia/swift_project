//
//  RegisMobileViewController.swift
//  SwiftApp

import UIKit
import JMButton
import RJNetworking_Swift

class RegisMobileViewController: RJViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    var forget: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var nextItem: RJAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        mobileTextField.addTarget(self, action: #selector(textFieldDidChanged(textField:)), for: .editingChanged)
        if forget {
            titleLabel.text = "忘记密码"
        }
        
        nextItem?.addTarget(target: self, action: #selector(nextAction), for: .touchUpInside)
    }
    
    @objc func nextAction() {
        let mobile = mobileTextField.text
        showProgressHUD()
        RJNetworking.CJNetworking().fetchCode(mobile!, type: forget ? 2 : 1) { [unowned self] response in
            if response.code == Code.Success {
                self.hideProgressHUD()
                let code = self.storyboard?.instantiateViewController(withIdentifier: "code") as! RegisCodeViewController
                code.mobile = mobile
                code.fetchCode = response.response?["code"].intValue
                code.forget = self.forget
                self.navigationController?.pushViewController(code, animated: true)
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    @objc func textFieldDidChanged(textField: UITextField) {
        if let str = textField.text {
            nextItem?.isEnable = str.count >= 11
            if str.count > 11 {
                let endIndex = str.index(str.startIndex, offsetBy: 10)
                textField.text = String(str[...endIndex])
            }
        } else {
            nextItem?.isEnable = false
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


