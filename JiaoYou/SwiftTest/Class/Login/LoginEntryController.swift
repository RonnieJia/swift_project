//
//  LoginEntryController.swift
//  SwiftApp

import UIKit

class LoginEntryController: RJViewController {

    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var regisBtn: UIButton!
    
    @IBOutlet weak var testBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        regisBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        testBtn.addTarget(self, action: #selector(cancelButtonHighlight(_:)), for: .allEvents)
        view.backgroundColor = .black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func btnTouchDown(_ sender: UIButton) {
        sender.backgroundColor = .lightGray
    }
    
    @IBAction func clickButton(_ sender: UIButton) {
        if sender.tag == 102 {
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = .white
        }
    }
    
    @objc func cancelButtonHighlight(_ sender: UIButton) {
        sender.isHighlighted = false
    }
    
    @IBAction func cancelButtonSelected(_ sender: UIButton) {
        if sender.tag == 102 {
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = .white
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
