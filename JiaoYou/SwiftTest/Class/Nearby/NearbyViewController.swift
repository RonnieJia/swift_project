//
//  NearbyViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/8.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import MJRefresh
import JMessage
import RJNetworking_Swift

class NearbyViewController: RJViewController {
    lazy var sortVC: ScreenViewController = {
        let sort = ScreenViewController()
        sort.sortBlock = {
            self.tableView.mj_header?.beginRefreshing()
        }
        return sort
    }()
    
    var fetchDataed: Bool = false
    
    var dataArray: [HomeModel] = []
    
    var topView: UIView?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "附近的人"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeCity), name: NSNotification.Name(rawValue: "changecity"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(blackUser), name: Notification.Name.init(rawValue: "blackUser"), object: nil)
        
        createNavRightBtn()
        
        topView = UIView()
        view.addSubview(topView!)
        topView?.backgroundColor = RGBAColor(34, 34, 34, 1)
        topView?.mas_makeConstraints { make in
            make?.top.and().left().and().right().mas_equalTo()(0)
            make?.height.mas_equalTo()(0)//36
        }
        let closeBtn = RJImageButton(image: UIImage(named: "close002"))
        topView?.addSubview(closeBtn)
        closeBtn.mas_makeConstraints { (make) in
            make?.top.and().bottom().mas_equalTo()(0)
            make?.right.mas_equalTo()(-10)
            make?.width.mas_equalTo()(30)
        }
        closeBtn.addTarget(self, action: #selector(closeNotiView), for: .touchUpInside)
        let notiBtn = RJTextButton( font: kDetailFont, textColor: .white, backgroundColor: RGBAColor(34, 34, 34, 1), text: "桃花同城交友绿色公约")
        notiBtn.contentHorizontalAlignment = .left
        notiBtn.setImage(UIImage(named: "voice001"), for: .normal)
        topView?.addSubview(notiBtn)
        notiBtn.mas_makeConstraints { (make) in
            make?.left.and()?.top()?.and()?.bottom()?.mas_equalTo()(0)
            make?.right.equalTo()(closeBtn.mas_left)?.offset()(-10)
        }
        notiBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        notiBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        notiBtn.addTarget(self, action: #selector(agreementPush), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = kScreenWidth + 80
        view.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(topView?.mas_bottom)
            make?.left.bottom()?.right()?.mas_equalTo()(0)
        }
        
        tableView.mj_header = MJRefreshStateHeader(refreshingBlock: { [weak self] in
            
                self?.fetchDataed = true
                self?.fetchData()
            
            
            
        })
        
//        tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: { [weak self] in
//            self?.page += 1
//            self?.fetchData()
//        })
        
        tableView.mj_header?.beginRefreshing()
    }
    
    @objc private func blackUser() {
        tableView.mj_header?.beginRefreshing()
    }
    
    @objc private func changeCity() {
        self.fetchData()
    }
    
    private func dataSort() {
        if self.dataArray.count > 0 {
            self.showProgressHUD()
            var temp = self.dataArray
            var arr: [HomeModel] = []
            while temp.count > 0 {
                let count = temp.count
                let index = arc4random_uniform(UInt32(count))
                arr.append(temp[Int(index)])
                temp.remove(at: Int(index))
            }
            self.dataArray = arr
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            self.hideProgressHUD()
        } else {
            self.fetchData()
        }
    }
    @objc func agreementPush() {
        let agree = HelpGuideViewController()
        agree.type = 3
        self.navigationController?.pushViewController(agree, animated: true)
    }
    @objc func closeNotiView() {
        topView?.mas_updateConstraints({ (make) in
            make?.height.mas_equalTo()(0)
        })
    }
    
    fileprivate func createNavRightBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "screen001")!.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(pushToScreen))
    }
    
    @objc func pushToScreen() {
        self.navigationController?.pushViewController(self.sortVC, animated: true)
    }
}

extension NearbyViewController {
    func fetchData() {
        showProgressHUD()
        RJNetworking.CJNetworking().nearbyList(self.page, heightStart: self.sortVC.heightStart, heightEnd: self.sortVC.heightEnd, ageStart: self.sortVC.ageStart, ageEnd: self.sortVC.ageEnd, city: self.sortVC.city, star: self.sortVC.starStr, state: self.sortVC.state, video: self.sortVC.video) { (response) in
            self.tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                if let arr: [HomeModel] = HomeModel.homeListArr(list: response.response) {
//                    if self.page == 1 {
                        self.dataArray.removeAll()
//                    }
                    self.dataArray += arr
                    self.tableView.reloadData()
//                    if arr.count < 10 {
//                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                    } else {
//                        self.tableView.mj_footer?.endRefreshing()
//                    }
                }
//                else {
//                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                }
                self.hideProgressHUD()
            } else {
//                if self.page > 1 {
//                    self.page -= 1
//                    self.tableView.mj_footer?.endRefreshing()
//                }
                self.hideProgressHUD(message: response.message)
            }
        }
    }
}

extension NearbyViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HomeCell.cell(with: tableView)
        cell.clickBlock = { [weak self] (hId, type) in
            if CurrentUser.isVisitor() {// 游客模式
                self?.showLoginAlert()
            } else {
                if type == 1 {// 聊天
                    if let model = self?.dataArray[indexPath.row] {
                        self?.chat(with: model)
                    }
                } else if (type == 2) {// 关注
                    self?.follow(indexPath.row)
                }
            }
        }
        cell.model = self.dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let detail = DetailViewController()
        detail.likeBlock = { [unowned self] (index, follow) in
            if index < self.dataArray.count {
                var user = self.dataArray[index]
                user.follow = follow
                self.dataArray[index] = user
                self.tableView.reloadData()
            }
        }
        detail.homeIndex = indexPath.row
        detail.user = self.dataArray[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    private func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    
    private func chat(with user: HomeModel) {
        guard VipManager.shared.nearbyCanChat(user.user_id!) else {
            VipView.show {
                self.showVipView()
            }
            return
        }
        JMSGConversation.createSingleConversation(withUsername: user.jmuserName) { (result, error) in
            if let conversion = result as? JMSGConversation {
                let chatVC = ChatViewController(conversation: conversion)
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                self.showMessage(message: "发生错误，稍后再试")
            }
        }
        
    }
    
    private func follow(_ index: NSInteger) {
        if index < self.dataArray.count {
            var user = self.dataArray[index]
            if user.user_id! == CurrentUser.sharedInstance.userId {
                showMessage(message: "不能关注自己~")
                return
            }
            showProgressHUD()
            RJNetworking.CJNetworking().followUser(user.user_id!) { (response) in
                if response.code == .Success {
                    if let cancel = response.message?.contains("取关"), cancel {
                        user.follow = 2
                    } else {
                        user.follow = 1
                    }
                    self.dataArray[index] = user
                    self.tableView.reloadData()
                }
                self.hideProgressHUD(message: response.message)
                
            }
        }
    }
    
}

