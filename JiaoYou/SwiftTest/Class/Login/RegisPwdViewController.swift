//
//  RegisPwdViewController.swift
//  SwiftApp

import UIKit
import RJNetworking_Swift

class RegisPwdViewController: RJViewController {
    var forget: Bool = false
    
    var phone: String?
    var code: String?
    
    @IBOutlet weak var compleItem: RJAnimationView!
    @IBOutlet weak var pedTextField: UITextField!
    
    @IBOutlet weak var agreeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        compleItem.addTarget(target: self, action: #selector(complePwdAction), for: .touchUpInside)
    }
    
    @objc func complePwdAction() {
        showProgressHUD()
        if !forget {
            RJNetworking.CJNetworking().regis(phone!, pwd: pedTextField.text!, code: code!) { (response) in
                if response.code == Code.Success {
                    CurrentUser.sharedInstance.userId = response.response?["uid"].intValue ?? -1
                    self.navigationController?.pushViewController(PrefectInfoViewController(), animated: true)
                    self.hideProgressHUD()
                } else {
                    self.hideProgressHUD(message: response.message)
                }
            }
            
        } else {
            RJNetworking.CJNetworking().forgetPwd(phone!, pwd: pedTextField.text!, code: code!) { (response) in
                if response.code == Code.Success {
                    if let viewcontrollers = self.navigationController?.viewControllers {
                        for vc in viewcontrollers {
                            if vc.isKind(of: LoginViewController.self) {
                                self.navigationController?.popToViewController(vc, animated: true)
                                break
                            }
                        }
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.hideProgressHUD()
                } else {
                    self.hideProgressHUD(message: response.message)
                }
            }
        }
    }
    
    @IBAction func pushAgreement(_ sender: UIButton) {
        let agree = HelpGuideViewController()
        agree.type = 2
        self.navigationController?.pushViewController(agree, animated: true)
    }
    
    @IBAction func agreeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
