//
//  DynamicDetailViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/29.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import RJNetworking_Swift
import JMessage
import MJRefresh

class DynamicDetailViewController: RJViewController {
    
    var followBlock: ((_ follow: Int) -> Void)?
    var likeBlock: ((_ follow: Int) -> Void)?
    
    let cellIdentifier = "commentCell"
    
    var society: SocietyModel
    
    var dataArr: [CommentModel] = []
    
    var inputTextField: UITextField?
    
    public required init(society model: SocietyModel) {
        self.society = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "详情"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 0, left: 0, bottom: safeBottom(50), right: 0))
        }
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 30))
        tableView.tableHeaderView = self.headerView
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 52.0
        tableView.mj_header = MJRefreshStateHeader(refreshingBlock: {
            self.fetchComList()
        })
        
        _setupInputView()
        fetchComList()
    }
    
    private func _setupInputView() {
        let inputView = UIView()
        view.addSubview(inputView)
        inputView.backgroundColor = .white
        inputView.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.and()?.bottom().mas_equalTo()(0)
            make?.height.mas_equalTo()(safeBottom(50))
        }
        
        inputTextField = UITextField()
        inputView.addSubview(inputTextField!)
        inputTextField?.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 10, left: 15, bottom: safeBottom(10), right: 15))
        }
        inputTextField?.cornerRadius = 15
        inputTextField?.font = UIFont.systemFont(ofSize: 12)
        inputTextField?.returnKeyType = .send
        inputTextField?.backgroundColor = ViewControllerLightGray()
        inputTextField?.placeholder = "有什么想要说的么"
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 30))
        inputTextField?.leftView = leftView
        inputTextField?.leftViewMode = .always
        inputTextField?.delegate = self
        let imgView = UIImageView(frame: CGRect(x: 15, y: 8, width: 14, height: 14))
        imgView.image = UIImage(named: "edit")
        leftView.addSubview(imgView)
    }
    
    func fetchComList() {
        showProgressHUD()
        RJNetworking.CJNetworking().societyComList(self.society.show_id) { (response) in
            self.tableView.mj_header?.endRefreshing()
            if response.code == .Success {
                let arr = CommentModel.listArr(list: response.response)
                self.dataArr.removeAll()
                self.dataArr += arr
                self.tableView.reloadData()
                self.hideProgressHUD()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
    
    private func jubaoSoc(_ model: SocietyModel) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { [weak self] (action) in
            let report = ReportViewController()
            report.uid = model.user_id
            self?.navigationController?.pushViewController(report, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func chat(with user: SocietyModel) {
        self.inputTextField?.becomeFirstResponder()
    }
    
    private func followAction() {

        if self.society.user_id == CurrentUser.sharedInstance.userId {
            showMessage(message: "不能关注自己~")
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().followUser(self.society.user_id) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取关"), cancel {
                    self.society.follow = 2
                } else {
                    self.society.follow = 1
                }
                self.headerView.followBtn?.isSelected = self.society.follow == 1
                if self.followBlock != nil {
                    self.followBlock!(self.society.follow)
                }
            }
            self.hideProgressHUD(message: response.message)
            
        }
        
    }
    
    private func likeAction() {
        showProgressHUD()
        RJNetworking.CJNetworking().likeShow(self.society.show_id) { (response) in
            if response.code == .Success {
                if let cancel = response.message?.contains("取消"), cancel {
                    self.society.like_num -= 1
                    self.society.like = 2
                } else {
                    self.society.like_num += 1
                    self.society.like = 1
                }
                self.headerView.model = self.society
                if self.likeBlock != nil {
                    self.likeBlock!(self.society.like)
                }
            }
            self.hideProgressHUD(message: response.message)
            
        }
        
    }
    
    lazy var headerView: DynamicDetailHeader = {
        let h = DynamicDetailHeader()
        h.model = self.society
        h.jubaoBlock = {
            self.jubaoSoc(self.society)
        }
        h.chatBlock = {
            self.chat(with: self.society)
        }
        h.likeBlock = {
            self.likeAction()
        }
        h.followBlock = {
            self.followAction()
        }
        return h
    }()
}

extension DynamicDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        commitContent()
        return true
    }
    
    func showVipView() {
        let story = UIStoryboard(name: "Mine", bundle: nil)
        let vip = story.instantiateViewController(withIdentifier: "vipcenter")
        self.navigationController?.pushViewController(vip, animated: true)
    }
    
    func commitContent() {
        guard let content = self.inputTextField?.text else {
            showMessage(message: "请输入内容~")
            return
        }
        guard VipManager.shared.userComment(self.society.show_id) else {
            VipView.show {
                self.showVipView()
            }
            return
        }
        showProgressHUD()
        RJNetworking.CJNetworking().commentSociety(content: content, showId: self.society.show_id) { (response) in
            if response.code == .Success {
                self.inputTextField?.text = nil
                self.hideProgressHUD()
                self.society.com_num += 1
                self.headerView.model = self.society
                self.fetchComList()
            } else {
                self.hideProgressHUD(message: response.message)
            }
        }
    }
}

extension DynamicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
        cell.model = dataArr[indexPath.row]
        return cell
    }
    
    
}
