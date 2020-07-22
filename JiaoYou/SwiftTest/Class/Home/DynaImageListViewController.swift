//
//  DynaImageListViewController.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/4/28.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import MJRefresh
import JMessage

class DynaImageListViewController: RJViewController {
    
    let CellIdeitifier = "dynaCell"
    
    var user: HomeModel?
    
    var dataArr: [SocietyModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user != nil {
            title = "\(user!.nickname!)的动态"
        }
        if self.user?.user_id != CurrentUser.sharedInstance.userId {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more002")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(blackItemAction))
        }
        view.addSubview(tableView)
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ImageListTableViewCell", bundle: nil), forCellReuseIdentifier: CellIdeitifier)
        tableView.mj_header = MJRefreshStateHeader(refreshingBlock: { [weak self] in
            self?.page = 1
            self?.fetchList()
        })
        tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: { [weak self] in
            self?.page += 1
            self?.fetchList()
        })
        
        tableView.mj_header?.beginRefreshing()
    }
    
    private func fetchList() {
        guard let uid = user?.user_id else {
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().userShows(uid, page: self.page) { (response) in
            self.tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                let arr = SocietyModel.listArr(list: response.response)
                if self.page == 1 {
                    self.dataArr.removeAll()
                }
                self.dataArr += arr
                if arr.count < 5 {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer?.endRefreshing()
                }
                self.tableView.reloadData()
                self.hideProgressHUD()
            } else {
                if self.page > 1 {// 加载更多出错，回滚
                    self.tableView.mj_footer?.endRefreshing()
                    self.page -= 1
                }
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    @objc private func blackItemAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let lhAction = UIAlertAction.init(title: "拉黑", style: .default, handler: { [weak self] (action) in
            self?.blacklistUser()
        })
        lhAction.setValue(UIColor.black, forKey: "_titleTextColor")
        actionSheet.addAction(lhAction)
        
        actionSheet.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { [weak self] (action) in
            self?.navigationController?.pushViewController(ReportViewController(), animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func blacklistUser() {
        let alert = UIAlertController(title: nil, message: "拉黑该用户？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "拉黑", style: .destructive, handler: { [weak self] (action) in
            self?.userMoveBlacklist()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func userMoveBlacklist() {
        showProgressHUD()
        RJNetworking.CJNetworking().blackUser(self.user!.user_id!) { (response) in
            let jmUser = self.user!.jmuserName
            if response.message?.contains("取消") == true{
            } else {// 拉黑成功
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
                    self.navigationController?.popToRootViewController(animated: true)
                })
                NotificationCenter.default.post(name: Notification.Name.init(rawValue: "blackUser"), object: nil)
                CurrentUser.blackUser(jmUser, dele: false)
            }
            self.hideProgressHUD(message: response.message)
        }
        
    }

}

extension DynaImageListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdeitifier, for: indexPath) as! ImageListTableViewCell
        cell.model = self.dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = self.dataArr[indexPath.row]
        model.nickname = self.user?.nickname ?? " "
        model.age = self.user?.age ?? 0
        model.constellation = self.user?.constellation ?? " "
        let detail = DynamicDetailViewController(society: model)
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = self.dataArr[indexPath.row].show_img.count
        if count == 0 {
            return 0
        }
        if  count == 1 {
            return autoSize(200) + 110
        } else if count == 2 {
            return autoSize(140) + 110
        } else if count == 3 {
            return (kScreenWidth - 35 - 40) / 3.0 + 110
        } else {
            return (kScreenWidth - 35 - 40) / 3.0 * 2 + 120
        }
    }
    
}
