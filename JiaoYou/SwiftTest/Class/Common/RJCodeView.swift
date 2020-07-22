//
//  RJCodeView.swift
//  SwiftApp
//
//  Created by jia on 2020/4/10.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import Masonry
import RJUtils_Swift

protocol RJCodeViewDelegate {
    func codeCompletion(enable: Bool)
}

class RJCodeField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
}

class RJCodeView: UIView, UITextFieldDelegate {
    var delegate: RJCodeViewDelegate?
    
    static var codeCount = 6
    var textField = RJCodeField()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(textField)
        textField.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }
        textField.keyboardType = UIKeyboardType.numberPad
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.addTarget(self, action: #selector(textFieldDidChanged(textField:)), for: .editingChanged)
//        textField.placeholder = "输入短信验证码"
        
        let wid: CGFloat = (kScreenWidth - 40 - 15.0 * (CGFloat(RJCodeView.codeCount) - 1)) / CGFloat(RJCodeView.codeCount)
        var left: MASViewAttribute?
        
        for i in 0 ..< RJCodeView.codeCount {
            let label = RJLabel(font: UIFont.systemFont(ofSize: 24), textColor: codeIColor, textAlignment: .center)
            addSubview(label)
            label.tag = 100 + i
            label.text = i == 0 ? "|" : nil
            label.mas_makeConstraints { (make) in
                if i == 0 {
                    make?.left.mas_equalTo()(20)
                } else {
                    make?.left.equalTo()(left)?.offset()(15)
                }
                make?.top.and().bottom()?.mas_equalTo()(0)
                make?.width.mas_equalTo()(wid)
            }
            left = label.mas_right
            
            let line = UIView()
            self.addSubview(line)
            line.backgroundColor = RJViewColor.septorLine.viewColor()
            line.mas_makeConstraints { (make) in
                make?.left.and()?.right()?.equalTo()(label)
                make?.height.mas_equalTo()(0.8)
                make?.bottom.mas_equalTo()(-10)
            }
        }
    }
    
    @objc func textFieldDidChanged(textField: UITextField) {
        var arr = [Character]()
        if let str = textField.text {
            if str.count > RJCodeView.codeCount {
                let endIndex = str.index(str.startIndex, offsetBy: 3)
                textField.text = String(str[...endIndex])
            }
            arr = textField.text!.map{ $0 }
        }
        if arr.count < RJCodeView.codeCount {
            arr.append("|")
        }
        delegate?.codeCompletion(enable: textField.text?.count == RJCodeView.codeCount)
        for i in 0 ..< RJCodeView.codeCount {
            let label = self.viewWithTag(i+100) as! UILabel
            if arr.count > i {
                let text = String(arr[i])
                if text == "|" {
                    label.textColor = codeIColor
                    label.font = UIFont.systemFont(ofSize: 24)
                } else {
                    label.font = UIFont.boldSystemFont(ofSize: 30)
                    label.textColor = codeTextColor
                }
                label.text = text
            } else {
                label.text = nil
            }
        }
        
    }
    
    
    lazy var codeIColor: UIColor = {
        var blue = UIColor.systemBlue
        if #available(iOS 13.0, *) {
            blue = UIColor { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .light {
                    return UIColor.systemBlue
                } else {
                    return UIColor.white
                }
            }
        }
        return blue
    }()
    
    lazy var codeTextColor: UIColor = {
        var blue = UIColor.black
        if #available(iOS 13.0, *) {
            blue = UIColor { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .light {
                    return UIColor.black
                } else {
                    return UIColor.white
                }
            }
        }
        return blue
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
}
