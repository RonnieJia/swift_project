//
//  ConversationTableViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JMessage

class ConversationTableViewCell: UITableViewCell {
    
    private func _init() {
        contentView.addSubview(avatorView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(msgLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(redPoint)
        
        avatorView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(15)
            make?.width.and()?.height()?.mas_equalTo()(46)
            make?.centerY.mas_equalTo()(0)
        }
        
        dateLabel.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-15)
            make?.bottom.equalTo()(avatorView.mas_bottom)?.offset()(-6)
            make?.width.equalTo()(80)
        }
        
        redPoint.mas_makeConstraints { (make) in
            make?.right.equalTo()(dateLabel.mas_right)
            make?.bottom.equalTo()(dateLabel.mas_top)?.offset()(-5)
            make?.height.mas_equalTo()(12)
            make?.width.mas_greaterThanOrEqualTo()(12)
        }
        
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(avatorView.mas_right)?.offset()(8)
            make?.top.equalTo()(avatorView.mas_top)?.offset()(6)
            make?.right.equalTo()(redPoint.mas_left)?.offset()(-8)
        }
        
        msgLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.bottom.equalTo()(dateLabel.mas_bottom)
            make?.right.equalTo()(dateLabel.mas_left)?.offset()(-8)
        }
    }
    
    func bindConversation(_ conversation: JMSGConversation) {
        let isGroup = conversation.ex.isGroup
        
        if let unreadCount = conversation.unreadCount?.intValue, unreadCount > 0 {
            redPoint.isHidden = false
            var text = ""
            if unreadCount > 99 {
                text = "99+"
                redPoint.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(30)
                }
            } else {
                redPoint.mas_updateConstraints { (make) in
                    make?.width.mas_equalTo()(unreadCount > 9 ? 18 : 12)
                }
                text = "\(unreadCount)"
            }
            redPoint.text = text
        } else {
            redPoint.isHidden = true
        }
        if let lastMsg = conversation.latestMessage {
            let time = lastMsg.timestamp.intValue / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            dateLabel.text = date.conversationDate()
        } else {
            dateLabel.text = ""
        }
        msgLabel.text = conversation.latestMessageContentText()
        
        if !isGroup {
            let user = conversation.target as? JMSGUser
            nameLabel.text = user?.displayName() ?? "用户(\(user!.uid))"
            user?.thumbAvatarData({ (data, _, _) in
                guard let imageData = data else {
                    self.avatorView.image = UIImage(named: "defaultUserIcon")
                    return
                }
                let image = UIImage(data: imageData)
                self.avatorView.image = image
            })
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _init()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    lazy var avatorView: UIImageView = {
        let avator = UIImageView()
        avator.contentMode = .scaleToFill
        avator.clipsToBounds = true
        avator.layer.cornerRadius = 23
        return avator
    }()
    
    lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 14)
        name.textColor = UIColor.black
        return name
    }()
    
    lazy var msgLabel: UILabel = {
       let msg = UILabel()
        msg.font = UIFont.systemFont(ofSize: 12)
        msg.textColor = UIColor.systemGray
        return msg
    }()
    
    lazy var dateLabel: UILabel = {
        let date = UILabel()
        date.font = UIFont.systemFont(ofSize: 12)
        date.textColor = UIColor.systemGray
        date.textAlignment = .right
        return date
    }()
    
    lazy var redPoint: UILabel = {
        let red = UILabel()
        red.textAlignment = .center
        red.font = UIFont.systemFont(ofSize: 10)
        red.textColor = .white
        red.layer.backgroundColor = UIColor.red.cgColor
        red.layer.cornerRadius = 6.0
        return red
    }()

}
