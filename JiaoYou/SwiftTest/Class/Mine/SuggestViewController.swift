//
//  SuggestViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class SuggestViewController: RJViewController, UITextViewDelegate {
    
    var userInfo: Bool = false
    
    var textNum: Int = 500
    
    var editUserInfo: ((_ str: String) -> Void)?
    
    var showText: String?

    @IBOutlet weak var completeBtn: RJAnimationView!
    @IBOutlet weak var commitBtn: RJAnimationView!
    
    @IBOutlet weak var textNumberLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ViewControllerLightGray()
        commitBtn?.addTarget(target: self, action: #selector(commitAction), for: .touchUpInside)
        
        if userInfo {
            commitBtn.isHidden = true
            completeBtn.isHidden=false
            textNum = 200
            placeLabel.text = "说出你的优点"
            title = "自我介绍"
            commitBtn?.title = "保存"
            textNumberLabel.text = "0/200"
            
            if self.showText != nil {
                self.textView.text = self.showText!
                textNumberLabel.text = "\(self.showText!.count)/200"
                placeLabel.isHidden = true
            }
            
            completeBtn.addTarget(target: self, action: #selector(completeAction), for: .touchUpInside)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeLabel.isHidden = !textView.text.isEmpty
        self.commitBtn.isEnable = !textView.text.isEmpty
        let count = textView.text.count
        if count > textNum {
            let str = textView.text!
            let endIndex = str.index(str.startIndex, offsetBy: textNum)
            textView.text = String(str[...endIndex])
        }
        self.textNumberLabel.text = "\(textView.text.count)/\(textNum)"
    }
    
    @objc func completeAction() {
        guard !self.textView.text.isEmpty else {
            showMessage(message: userInfo ? "请输入自我介绍" : "请输入您的建议")
            return
        }
        if userInfo {
            if self.editUserInfo != nil {
                self.editUserInfo!(self.textView.text)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func commitAction() {
        guard !self.textView.text.isEmpty else {
            showMessage(message: userInfo ? "请输入自我介绍" : "请输入您的建议")
            return
        }
        if userInfo {
            if self.editUserInfo != nil {
                self.editUserInfo!(self.textView.text)
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            showProgressHUD()
            RJNetworking.CJNetworking().suggest(self.textView.text) { (response) in
                if response.code == .Success {
                    let deadline = DispatchTime.now() + 0.8
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.hideProgressHUD(message: response.message)
            }
        }
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
