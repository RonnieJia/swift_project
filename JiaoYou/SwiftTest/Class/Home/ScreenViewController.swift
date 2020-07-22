//
//  ScreenViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/8.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJUtils_Swift
import Masonry
import JMButton

class ScreenViewController: RJViewController, UITableViewDelegate, UITableViewDataSource {

    var star: String = "不限"
    var heigh: String = "不限"
    var age: String = "不限"
    var cityStr: String = "不限"
    
    var sortBlock: (() -> Void)?
    
    var ageStart: String? = nil
    var ageEnd: String? = nil
    var heightStart: String? = nil
    var heightEnd: String? = nil
    var starStr: String? = nil
    var state: Int? = nil
    var video: Int? = nil
    var city: Int? = nil
    
    var dataArray = [Any]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "筛选"
        view.backgroundColor = RJViewColor.grayBackground.viewColor()
        
        let config = JMWaveButtonConfig()
        config.highlightedColor = .lightGray
        config.bootstrapType = .none
        config.backgroundColor = RGBAColor(40, 243, 101, 1)
        config.title = "确定"
        config.cornerRadius = 20
        config.titleFont = RJTextFont.defaultText.textFont()
        let sureBtn = JMButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth-120, height: 40), buttonConfig: config)
        view.addSubview(sureBtn!)
        sureBtn?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(60)
            make?.right.mas_equalTo()(-60)
            make?.bottom.mas_equalTo()(-safeBottom(30.0))
            make?.height.mas_equalTo()(40)
        })
        sureBtn?.addTarget(self, action: #selector(sortAction), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RJViewColor.grayBackground.viewColor()
        tableView.rowHeight = 40.0
        tableView.sectionHeaderHeight = 43.0
        tableView.tableFooterView = UIView()
        view.addSubview(self.tableView)
        tableView.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.top().mas_equalTo()(0)
            make?.bottom.equalTo()(sureBtn?.mas_top)?.offset()(-30)
        }
    }
    
    @objc func sortAction() {
        if self.sortBlock != nil {
            self.sortBlock!()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScreenTableViewCell.cell(with: tableView)
        cell.indexPath = indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.setInfo(self.star)
            } else if indexPath.row == 1 {
                cell.setInfo(self.heigh)
            } else if (indexPath.row == 2) {
                cell.setInfo(self.age)
            } else if (indexPath.row == 3) {
                cell.setInfo(self.cityStr)
            } else if (indexPath.row == 4) {
                if self.video == nil {
                    cell.setInfo("不限")
                } else {
                    cell.setInfo(self.video == 1 ? "是" : "否")
                }
            }
        } else {
            if indexPath.row == 0 {
                cell.setInfo(self.cityStr)
            } else if indexPath.row == 1 {
                if self.video == nil {
                    cell.setInfo("不限")
                } else {
                    cell.setInfo(self.video == 1 ? "是" : "否")
                }
            } else {
                if self.state == nil {
                    cell.setInfo("不限")
                } else {
                    cell.setInfo(self.state == 1 ? "是" : "否")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                self.addressInputView.show()
                return
            }
            if indexPath.row == 4 {
                self.showStateAlert(indexPath.row)
                return
            }
            
            var type = SortType.age
            if indexPath.row == 0 {
                type = .star
            } else if (indexPath.row == 1) {
                type = .height
            }
            let sort = SortChooseView(type)
            if type == .star {
                sort.starChoose = { star in
                    if star == "不限" {
                        self.starStr = nil
                    } else {
                        self.starStr = star
                    }
                    self.star = star
                    self.tableView.reloadData()
                }
            } else {
                sort.limitChoose = { (start, end) in
                    if type == .age {
                        if start == "不限" {
                            self.ageStart = nil
                            self.ageEnd = nil
                            self.age = "不限"
                        } else {
                            self.ageStart = start
                            self.ageEnd = end
                            self.age = "\(start) - \(end)"
                        }
                    } else {
                        if start == "不限" {
                            self.heightStart = nil
                            self.heightEnd = nil
                            self.heigh = "不限"
                        } else {
                            self.heigh = "\(start) - \(end)"
                            self.heightStart = start
                            self.heightEnd = end
                            self.ageEnd = end
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            sort.show()
            
        } else {
            if CurrentUser.sharedInstance.vip < 2 {// 开通vip
                VipView.show {
                    self.showVipView()
                }
            } else {
                if indexPath.row == 0 {
                    self.addressInputView.show()
                } else {
                    self.showStateAlert(indexPath.row)
                }
            }
        }
    }
    
    private func showStateAlert(_ index: Int) {
        let alert = UIAlertController(title: index == 4 ? "视频认证" : "身份认证", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "不限", style: .default, handler: { (action) in
            if index == 2 {
                self.state = nil
            } else {
                self.video = nil
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in
            if index == 2 {
                self.state = 1
            } else {
                self.video = 1
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "否", style: .default, handler: { (action) in
            if index == 2 {
                self.state = 0
            } else {
                self.video = 0
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 43))
        header.backgroundColor = .white
        
        let titleL = UILabel()
        titleL.font = UIFont.boldSystemFont(ofSize: 15)
        titleL.textColor = RJTextColor.textDark.textColor()
        header.addSubview(titleL)
        titleL.mas_makeConstraints { make in
            make?.left.mas_equalTo()(15)
            make?.centerY.mas_equalTo()(0)
        }
        titleL.text = section == 0 ? "基本筛选" : "高级筛选"
        
        let septorLine = UIView()
        septorLine.backgroundColor = RJViewColor.septorLine.viewColor()
        header.addSubview(septorLine)
        septorLine.mas_makeConstraints { make in
            make?.left.and()?.right()?.and()?.bottom().mas_equalTo()(0)
            make?.height.mas_equalTo()(0.8)
        }
        
        return header
    }
    
    private lazy var addressInputView: InfoEditInputView = {
        let address = InfoEditInputView(.address2)
        address.addressChoose = { [unowned self] (str: String, cid: Int) in
            if cid == -1 {
                self.city = nil
                self.cityStr = "不限"
            } else {
                self.city = cid
                self.cityStr = str
            }
            self.tableView.reloadData()
        }
        return address
    }()
    
}
