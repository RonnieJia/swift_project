//
//  EditNickViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class EditNickViewController: RJViewController {

    @IBOutlet weak var nickTextField: UITextField!
    
    var zhiye: Bool?
    
    var nick: String?
    
    var editNickCompltion: ((_ nick: String) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ViewControllerLightGray()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(completionNick))
        
        nickTextField.placeholder = "请输入\(zhiye == true ? "职业" : "昵称")"
        if nick != nil {
            self.nickTextField.text = nick!
        }
        
        if zhiye == true {
            title = "职业"
        }
    }
    
    
    @objc func completionNick() {
        if nickTextField.text == nil || nickTextField.text!.isEmpty {
            showMessage(message: "请输入\(zhiye == true ? "职业" : "昵称")")
            return
        }
        if editNickCompltion != nil {
            editNickCompltion!(nickTextField.text!)
        }
        self.navigationController?.popViewController(animated: true)
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
