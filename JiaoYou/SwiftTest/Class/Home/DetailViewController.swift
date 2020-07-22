//
//  DetailViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/20.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import JXPhotoBrowser
import JMessage
import MJRefresh

class DetailViewController: RJViewController {
    
    var likeBlock: ((_ index: Int, _ follow: Int) -> Void)?
    
    var user: HomeModel?
    
    var homeIndex: Int?
    
    var imagesArr: [String] = []
    
    var userId: String?
    
    var collectionView: UICollectionView?
    
    var dataArray: [SocietyModel] = []
    
    lazy var header: DetailHeaderView = {
        let hea = DetailHeaderView()
        hea.followBlock = { [unowned self] (user, type) in
            if type == 0 {
                self.followAction(user)
            } else if type == 1 {
                self.chat(with: user)
            } else if (type == 2) {
                self.moreImages(user)
            }
        }
        hea.playVideoBlock = {
            if let videoPath = self.user?.video {
                let story = UIStoryboard(name: "Mine", bundle: nil)
                let video = story.instantiateViewController(withIdentifier: "videoplay") as! VideoPlayViewController
                video.user = self.user
                video.chat = true
                video.videoPath = videoPath
                video.followBlock = { (follow) in
                    self.user?.follow = follow
                    self.collectionView?.reloadData()
                    if self.likeBlock != nil && self.homeIndex != nil {
                        self.likeBlock!(self.homeIndex!, self.user?.follow ?? 2)
                    }
                }
                self.navigationController?.pushViewController(video, animated: true)
            }
            
        }
        return hea
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewBackgroundColor
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        tableView.register(UINib(nibName: "MineTableViewCell", bundle: nil), forCellReuseIdentifier: "mine")
        adjustsScrollViewInsets(tableView)
        _createNavigationBarView()
        fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        guard let uid = user?.user_id else {
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().userDetail(uid) { (response) in
            self.collectionView?.mj_header?.endRefreshing()
            if response.code == .Success {
                if var user = HomeModel.homeModel(result: response.response) {
                    user.video_state = self.user?.video_state
                    self.user = user
                    self.header.model = self.user
                    self.tableView.tableHeaderView = self.header
                }
            }
        }
        
        RJNetworking.CJNetworking().userShows(uid, page: self.page) { (response) in
            self.tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                let arr = SocietyModel.listArr(list: response.response)
                if self.page == 1 {
                    self.dataArray.removeAll()
                }
                self.dataArray += arr
                if arr.count < 10 {
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
    
    private func _createNavigationBarView() {
        let navigationBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: kNavigatioBarHeight))
        self.view.addSubview(navigationBar)
        
        let backBtn = RJImageButton(frame: CGRect(x: 10, y: kStatusBarHeight, width: 47, height: 44), image: UIImage(named: "back002"))
        navigationBar.addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(backToForeground), for: .touchUpInside)
        
        let setBtn = RJImageButton(frame: CGRect(x: kScreenWidth - 57, y: kStatusBarHeight, width: 47, height: 44), image: UIImage(named: "more001"))
        navigationBar.addSubview(setBtn)
        setBtn.addTarget(self, action: #selector(setBtnAction), for: .touchUpInside)
        
    }
    
    @objc func backToForeground() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setBtnAction() {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let lhAction = UIAlertAction.init(title: "拉黑", style: .default, handler: { [weak self] (action) in
            self?.blacklistUser()
        })
        lhAction.setValue(UIColor.black, forKey: "_titleTextColor")
        actionSheet.addAction(lhAction)
        
        actionSheet.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { [weak self] (action) in
            let report = ReportViewController()
            report.uid = self?.user?.user_id
            self?.navigationController?.pushViewController(report, animated: true)
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
            if response.code == .Success {
                let jmUser = self.user!.jmuserName
                if response.message?.contains("取消") == true{
                } else {// 拉黑成功
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: "blackUser"), object: nil)
                    CurrentUser.blackUser(jmUser, dele: false)
                }
            }
            self.hideProgressHUD(message: response.message)
        }
        
    }
    
}


extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mine", for: indexPath) as! MineTableViewCell
        cell.model = dataArray[indexPath.row]
        cell.niceBlock = {
            self.likeAction(tableView, index: indexPath.row)
        }
        return cell
    }
    
    
    private func likeAction(_ tableView: UITableView, index: Int) {
        if CurrentUser.isVisitor() {
            showLoginAlert()
            return
        }
        showProgressHUD()
        var soc = dataArray[index]
        RJNetworking.CJNetworking().likeShow(soc.show_id) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取消"), cancel {
                    soc.like_num -= 1
                    soc.like = 2
                } else {
                    soc.like_num += 1
                    soc.like = 1
                }
                self.dataArray[index] = soc
                tableView.reloadData()
            }
            self.hideProgressHUD(message: response.message)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = self.dataArray[indexPath.row]
        model.nickname = CurrentUser.sharedInstance.nickname ?? " "
        model.age = CurrentUser.sharedInstance.age
        model.constellation = CurrentUser.sharedInstance.constellation ?? " "
        let detail = DynamicDetailViewController(society: model)
        self.navigationController?.pushViewController(detail, animated: true)
    }
}


extension DetailViewController  {
    @objc func showImg(_ index: Int = 0) {
        guard index < imagesArr.count else {
            return
        }
        
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return self.imagesArr.count
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(self.imagesArr[context.index])"), placeholder: UIImage(named: ""))
        }
        let pageIndicator = JXPhotoBrowserNumberPageIndicator(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        browser.pageIndicator = pageIndicator
        browser.view.addSubview(pageIndicator)
        browser.pageIndex = index
        browser.reloadData()
        browser.show()
    }
}

extension DetailViewController {
    
    func chatAction(_ userModel: HomeModel) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        guard VipManager.shared.homeCanChat(userModel.user_id!) else {
            VipView.show {
                self.showVipView()
            }
            return
        }
        JMSGConversation.createSingleConversation(withUsername: userModel.jmuserName) { (result, error) in
            if let conversion = result as? JMSGConversation {
                let chatVC = ChatViewController(conversation: conversion)
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                self.showMessage(message: "发生错误，稍后再试")
            }
        }
    }
    func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    private func moreImages(_ userModel: HomeModel) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        let list = DynaImageListViewController()
        list.user = self.user
        navigationController?.pushViewController(list, animated: true)
    }
    private func followAction(_ userModel: HomeModel) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }

        if userModel.user_id! == CurrentUser.sharedInstance.userId {
            showMessage(message: "不能关注自己~")
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().followUser(userModel.user_id!) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取关"), cancel {
                    self.user?.follow = 2
                } else {
                    self.user?.follow = 1
                }
                self.header.model = self.user
                if self.likeBlock != nil && self.homeIndex != nil {
                    self.likeBlock!(self.homeIndex!, self.user?.follow ?? 2)
                }
            }
            self.hideProgressHUD(message: response.message)
            
        }
    }
    
    private func chat(with user: HomeModel) {
        if CurrentUser.isVisitor() {
            self.showLoginAlert()
            return
        }
        guard VipManager.shared.homeCanChat(user.user_id!) else {
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
}

