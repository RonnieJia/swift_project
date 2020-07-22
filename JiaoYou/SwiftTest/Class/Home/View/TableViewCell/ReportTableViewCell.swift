//
//  ReportTableViewCell.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/3.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    var containerView: UIView?
    var selectBtn: UIButton?
    var titleLabel: UILabel?
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        _setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupViews() {
        containerView = UIView()
        contentView.addSubview(containerView!);
        containerView?.cornerRadius = 4
        containerView?.borderColor = RGBAColor(225, 225, 225, 1.0)
        containerView?.borderWidth = 0.6
        containerView?.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.right.mas_equalTo()(-20)
            make?.top.and()?.bottom()?.mas_equalTo()(0)
        }
        
        selectBtn = RJImageButton(image: UIImage(named: "check001"), selectedImage: UIImage(named: "check001"))
        containerView?.addSubview(selectBtn!)
        
        titleLabel = RJLabel()
        containerView?.addSubview(titleLabel!)
        
        selectBtn?.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(-15)
            make?.centerY.mas_equalTo()(0)
            make?.width.and()?.height()?.mas_equalTo()(13)
        })
        
        titleLabel?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(25)
            make?.right.equalTo()(selectBtn?.mas_left)?.offset()(-10)
            make?.centerY.mas_equalTo()(0)
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectBtn?.isHidden = !selected

        // Configure the view for the selected state
    }

}
