//
//  CommentTableViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/4/29.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var model: CommentModel? {
        didSet {
            avatarImgView?.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(model!.avatarUrl)"), placeholder: UIImage(named: "defaultUserIcon"))
            nameLabel?.text = model?.nickname
            contentLabel?.text = model?.content
        }
    }
    
    var avatarImgView: UIImageView?
    var nameLabel: UILabel?
    var contentLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupViews() {
        avatarImgView = UIImageView()
        contentView.addSubview(avatarImgView!)
        avatarImgView?.cornerRadius = 16
        avatarImgView?.clipsToBounds = true
        avatarImgView?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(20)
            make?.top.mas_equalTo()(10)
            make?.width.and()?.height()?.mas_equalTo()(32)
        })
        
        nameLabel = RJLabel()
        contentView.addSubview(nameLabel!)
        nameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(avatarImgView?.mas_right)?.offset()(10)
            make?.top.equalTo()(avatarImgView?.mas_top)?.offset()(5)
            make?.right.mas_equalTo()(-15)
        })
        
        contentLabel = RJLabel()
        contentView.addSubview(contentLabel!)
        contentLabel?.numberOfLines = 0
        contentLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(nameLabel?.mas_left)
            make?.top.equalTo()(nameLabel?.mas_bottom)?.offset()(10)
            make?.right.equalTo()(nameLabel?.mas_right)
            make?.bottom.mas_equalTo()(-10)
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
