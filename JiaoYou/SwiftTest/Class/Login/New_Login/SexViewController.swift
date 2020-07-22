//
//  SexViewController.swift
//  SwiftApp
//

import UIKit
import JMButton
import RJUtils_Swift
import JMessage

class SexViewController: RJViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var boyBtn: UIButton!
    @IBOutlet weak var girlBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }

    @IBAction func completionClickAction(_ sender: UIButton) {
        guard !boyBtn.isEnabled || !girlBtn.isEnabled else {
            showMessage(message: "请选择")
            return
        }
        if !boyBtn.isEnabled {
            CurrentUser.sharedInstance.userSex = .boy
        } else {
            CurrentUser.sharedInstance.userSex = .girl
        }
        CurrentUser.sharedInstance.userId = -1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = RJTabBarController()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func chooseSex(_ sender: UIButton) {
        girlBtn.isEnabled = true
        boyBtn.isEnabled = true
        sender.isEnabled = false
    }
}

