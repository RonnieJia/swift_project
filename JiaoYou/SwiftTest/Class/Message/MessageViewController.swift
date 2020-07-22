//
//  MessageViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/3.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JMessage

private class ConversionBtn: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView!.frame = CGRect(x: (self.width - 39) / 2.0, y: 14, width: 39, height: 39)
        
        self.titleLabel?.frame = CGRect(x: 0, y: 14 + 39 + 5, width: self.width, height: 15)
    }
}

class MessageViewController: RJViewController {

    var kefuMsgNum: UILabel?
    var datas: [JMSGConversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
        _getConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _getConversations()
    }
    
    private func _init() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.backgroundColor = ViewControllerLightGray()
        tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        tableView.rowHeight = 66
        tableView.backgroundColor = .white
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: "JCConversationCell")
        
        let wid = kScreenWidth / 2.0 - 10
        let titles = ["chaticon001_1", "chaticon002_1"]
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: wid * 34 / 183 + 14))
        headerView.backgroundColor = .white
        for i in 0 ..< 2 {
            let item = ConversionBtn(type: .custom)
            item.frame = CGRect(x: CGFloat(i) * (wid + 10) + 5, y: 5, width: wid, height: wid * 34 / 183)
            item.setBackgroundImage(UIImage(named: titles[i]), for: .normal)
            headerView.addSubview(item)
            item.tag = 100 + i
            item.addTarget(self, action: #selector(headerItemAction(_:)), for: .touchUpInside)
            if i == 0 {
                kefuMsgNum = RJLabel(frame: CGRect(x: item.width / 2 + 10, y: 4, width: 20, height: 20), font: UIFont.systemFont(ofSize: 10), textColor: .white, textAlignment: .center)
                kefuMsgNum?.cornerRadius = 10
                kefuMsgNum?.backgroundColor = .red
                kefuMsgNum?.adjustsFontSizeToFitWidth = true
                kefuMsgNum?.isHidden = true
//                item.addSubview(kefuMsgNum!)
            }
        }
        let line = UIView()
        line.backgroundColor = ViewControllerLightGray()
        headerView.addSubview(line)
        line.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.and()?.bottom().mas_equalTo()(0)
            make?.height.mas_equalTo()(4)
        }
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        _setupNavigationSubviews()
        JMessage.add(self, with: nil)
        
    }
    
    private func _setupNavigationSubviews() {
        title = "消息"
        let clearBtn = RJTextButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44), font: kDetailFont, text: "清空")
        clearBtn.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: clearBtn)
        
        let readBtn = RJTextButton(frame: CGRect(x: 0, y: 0, width: 50, height: 44), font: kDetailFont, text: "全部已读")
        readBtn.addTarget(self, action: #selector(readAllAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: readBtn)
    }
    
    @objc private func headerItemAction(_ sender: UIButton) {
        if sender.tag == 100 {
            JMSGConversation.createSingleConversation(withUsername: "kefu", completionHandler: { (result, error) in
                if let con = result as? JMSGConversation {
                    let chat = ChatViewController(conversation: con)
                    self.navigationController?.pushViewController(chat, animated: true)
                }
            })
        } else if sender.tag == 102 {
            navigationController?.pushViewController(VistorListViewController(), animated: true)
        } else {
            navigationController?.pushViewController(LikeListViewController(), animated: true)
        }
    }
    
    @objc private func clearAction() {
        showProgressHUD()
        JMSGConversation.allUnsortedConversations { [unowned self] (result, error) in
            guard error == nil else {
                self.hideProgressHUD(message: "清除失败，稍后再试~")
                return
            }
            guard let conversations = result as? [JMSGConversation] else {
                self.hideProgressHUD()
                return
            }
            for conversation in conversations {
                if conversation.conversationType == .single {
                    if let user = conversation.target as? JMSGUser {
                        JMSGConversation.deleteSingleConversation(withUsername: user.username)
                    }
                } else if conversation.conversationType == .group {
                    if let group = conversation.target as? JMSGGroup {
                        JMSGConversation.deleteGroupConversation(withGroupId: group.gid)
                    }
                } else if conversation.conversationType == .chatRoom {
                    if let room = conversation.target as? JMSGChatRoom {
                        JMSGConversation.deleteChatRoomConversation(withRoomId: room.roomID)
                    }
                }
            }
            self._getConversations()
            self.hideProgressHUD()
        }
    }
    
    @objc private func readAllAction() {
        showProgressHUD()
        self.kefuMsgNum?.isHidden = true
        JMSGConversation.allConversations { (result, error) in
            guard let conversations = result else {
                return
            }
            var unKFArr: [JMSGConversation] = []
            if let arr = conversations as? [JMSGConversation] {
                DispatchQueue.global().async {
                    for conver in arr {
                        conver.clearUnreadCount()
                        if conver.conversationType == .single {
                            let user = conver.target as! JMSGUser
                            if user.username != "kefu" {
                                unKFArr.append(conver)
                            } else {
                                self.kefuMsgNum?.isHidden = true
                            }
                        }
                    }
                    self.datas = unKFArr
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        CurrentUser.showMessageBadge(0)
                        self.hideProgressHUD()
                    }
                }
            } else {
                DispatchQueue.global().async {
                    for con in self.datas {
                        con.clearUnreadCount()
                    }
                    JMSGConversation.createSingleConversation(withUsername: "kefu") { (result, error) in
                        if let conversion = result as? JMSGConversation {
                            conversion.clearUnreadCount()
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        CurrentUser.showMessageBadge(0)
                        self.hideProgressHUD()
                    }
                }
            }
        }
        
        
    }
    
    private func _updateBadge() {
        DispatchQueue.global().async {
            let num = JMSGConversation.getAllUnreadCount().intValue
            CurrentUser.showMessageBadge(num)
        }
    }
    
    private func _getConversations() {
        JMSGConversation.allConversations { (result, error) in
            guard let conversations = result else {
                return
            }
            var unKFArr: [JMSGConversation] = []
            if let arr = conversations as? [JMSGConversation] {
                for conver in arr {
                    if conver.conversationType == .single {
                        let user = conver.target as! JMSGUser
                        if user.username != "kefu" {
                            unKFArr.append(conver)
                        } else {
                            if let num = conver.unreadCount?.intValue, num > 0 {
                                self.kefuMsgNum?.isHidden = false
                                self.kefuMsgNum?.text = "\(num)"
                            } else {
                                self.kefuMsgNum?.isHidden = true
                            }
                        }
                    }
                }
            }
            self.datas = unKFArr
            self.tableView.reloadData()
            self._updateBadge()
        }
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JCConversationCell", for: indexPath) as! ConversationTableViewCell
        cell.bindConversation(datas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = datas[indexPath.row]
        conversation.clearUnreadCount()
        let cell = tableView.cellForRow(at: indexPath)  as! ConversationTableViewCell
        cell.bindConversation(conversation)
        _updateBadge()
        let chat = ChatViewController(conversation: datas[indexPath.row])
        navigationController?.pushViewController(chat, animated: true)
    }
    
}

extension MessageViewController: JMessageDelegate {
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        _getConversations()
    }
    
    func onConversationChanged(_ conversation: JMSGConversation!) {
        _getConversations()
    }
    
    func onGroupInfoChanged(_ group: JMSGGroup!) {
        _getConversations()
    }
    
    func onSyncRoamingMessageConversation(_ conversation: JMSGConversation!) {
        _getConversations()
    }
    
    func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        _getConversations()
    }
    
    func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        _getConversations()
    }
}



