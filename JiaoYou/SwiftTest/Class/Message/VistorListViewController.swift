//
//  VistorListViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/26.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift

class VistorListViewController: RJViewController {

    var dataArray: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "访客"
        
        view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        _fetchVistorList()
    }
    
    private func _fetchVistorList() {
        showProgressHUD()
        RJNetworking.CJNetworking().vistorList { (response) in
            if response.code == .Success {
                let arr = response.response?["list"].array
                if arr != nil && arr?.count ?? 0 > 0 {
                    self.tableView.tableFooterView = self.footerView
                } else {
                    self.tableView.tableFooterView = self.nullView
                }
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    lazy var footerView: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        let moreBtn = RJTextButton(frame: CGRect(x: kScreenWidth / 2.0 - 110, y: 15, width: 220, height: 48), text: "升级会员查看更多访问")
        footer.addSubview(moreBtn)
        moreBtn.cornerRadius = 24
        moreBtn.borderColor = .darkGray
        moreBtn.borderWidth = 1
        return footer
    }()
    
    lazy var nullView: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        let label = RJLabel(frame: CGRect(x: 10, y: 20, width: kScreenWidth - 20, height: 20), textAlignment: .center, text: "暂无访客")
        footer.addSubview(label)
        return footer
    }()
}

extension VistorListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
}

