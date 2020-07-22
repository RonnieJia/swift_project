//
//  SortChooseView.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/5.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

enum SortType {
    case star
    case height
    case age
}

class SortChooseView: UIView {
    
    var type: SortType
    
    let keyboardHeight:CGFloat = 260.0
    
    var starChoose: ((_ text: String) -> Void)?
    var limitChoose: ((_ start: String, _ end: String) -> Void)?
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenHeight, height: safeBottom(keyboardHeight)))
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer())
        
        let line = UIView(frame: CGRect(x: 8, y: 40, width: kScreenWidth-16, height: 0.8))
        line.backgroundColor = UIColor.lightGray
        view.addSubview(line)
        
        let sureBtn = RJTextButton(frame: CGRect(x: kScreenWidth-50, y: 0, width: 45, height: 40), font: UIFont.systemFont(ofSize: 14), textColor: UIColor.darkGray, text: "确定")
        view.addSubview(sureBtn)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        
        view.addSubview(self.pickerView)
        return view
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: keyboardHeight - 41))
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var starArray: [String] = ["不限", "白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "摩羯座", "水瓶座", "双鱼座"]
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) {
            self.containerView.y(kScreenHeight - safeBottom(self.keyboardHeight))
        }
    }
    
    init(_ type: SortType = .star) {
        self.type = type
        super.init(frame: UIScreen.main.bounds)
        
        _init(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _init(_ type: SortType) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        addSubview(containerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func sureAction() {
        if self.type == .star {
            if self.starChoose != nil {
                let str = self.starArray[self.pickerView.selectedRow(inComponent: 0)]
                self.starChoose!(str)
            }
        } else if self.type == .height {
            let index = self.pickerView.selectedRow(inComponent: 0)
            let secIndex = self.pickerView.selectedRow(inComponent: 1)
            if index == 0 {
                if self.limitChoose != nil {
                    self.limitChoose!("不限", "不限")
                }
            } else {
                if self.limitChoose != nil {
                    self.limitChoose!("\(index + 150 - 1)", "\(150 + secIndex + index)")
                }
            }
        } else {
            let index = self.pickerView.selectedRow(inComponent: 0)
            let secIndex = self.pickerView.selectedRow(inComponent: 1)
            if index == 0 {
                if self.limitChoose != nil {
                    self.limitChoose!("不限", "不限")
                }
            } else {
                if self.limitChoose != nil {
                    self.limitChoose!("\(index + 18 - 1)", "\(18 + secIndex + index)")
                }
            }
        }
        hideSelf()
    }
    
    @objc private func hideSelf() {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.y(kScreenHeight)
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
}


extension SortChooseView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.type == .star {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.type == .star {
            return self.starArray.count
        } else if self.type == .height {
            if component == 0 {
                return 200 - 150 + 2
            } else {
                let select = pickerView.selectedRow(inComponent: 0)
                if select == 0 {
                    return 1
                } else {
                    return 220 - select
                }
            }
        } else {
            if component == 0 {
                return 60 - 18 + 1
            } else {
                let select = pickerView.selectedRow(inComponent: 0)
                if select == 0 {
                    return 1
                } else {
                    return 70 - select
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.type == .star {
            return starArray[row]
        } else if self.type == .height {
            if component == 0 {
                if row == 0 {
                    return "不限"
                }
                return "\(150 + row - 1)"
            } else {
                let select = pickerView.selectedRow(inComponent: 0)
                if select == 0 {
                    return "不限"
                } else {
                    return "\(150 + row + select)"
                }
            }
        } else {
            if component == 0 {
                if row == 0 {
                    return "不限"
                }
                return "\(18 + row - 1)岁"
            } else {
                let select = pickerView.selectedRow(inComponent: 0)
                if select == 0 {
                    return "不限"
                } else {
                    return "\(18 + row + select)岁"
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.type == .star {
        } else {
            if  component == 0 {
                self.pickerView.reloadComponent(1)
                self.pickerView.selectRow(0, inComponent: 1, animated: true)
            }
        }
    }
}

