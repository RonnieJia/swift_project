//
//  InfoEditInputView.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/4/25.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

enum InfoInputType {
    case date
    case height
    case address
    case address2
}

class InfoEditInputView: UIView {
    
    var type: InfoInputType
    
    let keyboardHeight:CGFloat = 260.0
    
    var datePicker: UIDatePicker?
    
    var editChoose: ((_ text: String) -> Void)?
    
    var addressChoose: ((_ address: String, _ cid: Int) -> Void)?
    
    var provinceList: [[String: Any]] = []
    
    var cityList: [String: [[String: Any]]] = [:]
    
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
        return view
    }()
    
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: keyboardHeight - 41))
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) {
            self.containerView.y(kScreenHeight - safeBottom(self.keyboardHeight))
        }
    }
    
    init(_ type: InfoInputType = .date) {
        self.type = type
        super.init(frame: UIScreen.main.bounds)
        
        _init(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _init(_ type: InfoInputType) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        addSubview(containerView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        self.addGestureRecognizer(tap)
        
        switch type {
        case .date:
            _setupDate()
        case .height:
            _setupHeightPicker()
        default:
            _setupAddressPicker()
            break
        }
    }
    
    @objc private func sureAction() {
        if self.type == .date {
            if let date = datePicker?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let str = dateFormatter.string(from: date)
                if self.editChoose != nil {
                    self.editChoose?(str)
                }
            }
        } else if self.type == .height {
            let row = pickerView.selectedRow(inComponent: 0)
            let str = "\(row+150)"
            if self.editChoose != nil {
                self.editChoose?(str)
            }
        } else {
            var selecIndex = self.pickerView.selectedRow(inComponent: 0)
            if self.type == .address2 {
                if selecIndex == 0 {
                    if self.addressChoose != nil {
                        self.addressChoose!("不限", -1)
                    }
                    hideSelf()
                    return
                } else {
                    selecIndex -= 1
                }
            }
            let pro = self.provinceList[selecIndex]
            let cityId = pro["id"] as! Int
            if cityId >= 32 {
                if self.addressChoose != nil {
                    self.addressChoose!(pro["name"] as! String, cityId)
                }
            } else {
                if let arr = self.cityList["\(cityId)"] {
                    let city = arr[self.pickerView.selectedRow(inComponent: 1)]
                    let cityId2 = city["id"] as! Int
                    var name = city["name"] as! String
                    if name == "市辖区" {
                        name = "\(pro["name"] as! String)市辖区"
                    }
                    if self.addressChoose != nil {
                        self.addressChoose!(name, cityId2)
                    }
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

/// datePicker
extension InfoEditInputView {
    private func _setupDate() {
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 41, width: kScreenWidth, height: keyboardHeight - 41))
        containerView.addSubview(datePicker!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "1960-01-01")
        datePicker?.minimumDate = date
        datePicker?.maximumDate = Date()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale(identifier: "zh_CN")
    }
}

extension InfoEditInputView {
    func _setupHeightPicker() {
        pickerView.selectRow(175-150, inComponent: 0, animated: false)
        containerView.addSubview(pickerView)
    }
}

extension InfoEditInputView {
    private func _setupAddressPicker() {
        containerView.addSubview(pickerView)
        self.fetchProvinceList()
    }
    
    private func fetchProvinceList() {
        showProgressHUD()
        RJNetworking.CJNetworking().cityList { [unowned self] (response) in
            if response.code == .Success {
                if let list = response.response?["list"].arrayObject as? [[String: Any]], list.count > 0 {
                    self.provinceList.removeAll()
                    self.provinceList = list
                    self.pickerView.reloadComponent(0)
                    let pro = list.first
                    if let id = pro?["id"] as? Int, id > 0 {
                        self.fetchCityList("\(id)")
                    } else {
                        self.hideProgressHUD()
                    }
                }
                
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    private func fetchCityList(_ city: String) {
        RJNetworking.CJNetworking().cityList(city) { [unowned self] (response) in
            if response.code == .Success {
                if let list = response.response?["list"].arrayObject as? [[String: Any]], list.count > 0 {
                    self.cityList[city] = list
                    self.pickerView.reloadComponent(1)
                    self.pickerView.selectRow(0, inComponent: 1, animated: true)
                }
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
}

extension InfoEditInputView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.type == .height {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.type == .height {
            return 220-149
        }
        if component == 0 {
            if self.type == .address2 {
                return self.provinceList.count + 1
            }
            return self.provinceList.count
        }
        if self.provinceList.count > 0 {
            var seleindex = self.pickerView.selectedRow(inComponent: 0)
            if self.type == .address2 {
                if seleindex == 0 {
                    return 1
                }
                seleindex -= 1
            }
            let pro = self.provinceList[seleindex]
            let cityId = pro["id"] as! Int
            if let arr = self.cityList["\(cityId)"] {
                return arr.count
            }
            
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.type == .height {
            return "\(150+row)"
        }
        var indexRow = row
        if component == 0 {
            if self.type == .address2 {
                if row == 0 {
                    return "不限"
                } else {
                    indexRow -= 1
                }
            }
            let dic = self.provinceList[indexRow]
            return (dic["name"] as! String)
        } else {
            var selectIndex = self.pickerView.selectedRow(inComponent: 0)
            if self.type == .address2 {
                if selectIndex == 0 {
                    return "不限"
                } else {
                    selectIndex -= 1
                }
            }
            let pro = self.provinceList[selectIndex]
            let cityId = pro["id"] as! Int
            if let arr = self.cityList["\(cityId)"] {
                let dic = arr[indexRow]
                return (dic["name"] as! String)
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.type == .address {
            if component == 0 {//
                let pro = self.provinceList[row]
                let cityId = pro["id"] as! Int
                if cityId >= 32 {
                    self.pickerView.reloadComponent(1)
                } else {
                    if let arr = self.cityList["\(cityId)"], arr.count > 0 {
                        self.pickerView.reloadComponent(1)
                        self.pickerView.selectRow(0, inComponent: 1, animated: true)
                    } else {
                        showProgressHUD()
                        self.fetchCityList("\(cityId)")
                    }
                }
            }
        } else if self.type == .address2 {
            if component == 0 {//
                if row == 0 {
                    self.pickerView.reloadComponent(1)
                    return
                }
                let pro = self.provinceList[row-1]
                let cityId = pro["id"] as! Int
                if cityId >= 32 {
                    self.pickerView.reloadComponent(1)
                } else {
                    if let arr = self.cityList["\(cityId)"], arr.count > 0 {
                        self.pickerView.reloadComponent(1)
                        self.pickerView.selectRow(0, inComponent: 1, animated: true)
                    } else {
                        showProgressHUD()
                        self.fetchCityList("\(cityId)")
                    }
                }
            }
        }
    }
}


