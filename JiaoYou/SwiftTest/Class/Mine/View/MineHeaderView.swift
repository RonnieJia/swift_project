//
//  MineHeaderView.swift
//  SwiftApp
//
//  Created by jia on 2020/6/1.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class MineHeaderView: UIView {

    var itemBlock: ((_ index: Int) -> ())?
    
    func displayInfo() {
        let user = CurrentUser.sharedInstance
        if user.avatarUrl != nil {
            avatarImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(user.avatarUrl!)"), placeholder: UIImage(named: "defaultUserIcon"))
        } else {
            avatarImgView.image = UIImage(named: "defaultUserIcon")
        }
        nameLabel.text = user.nickname
        ageBtn.setTitle("\(user.age)岁", for: .normal)
        starBtn.setTitle(user.constellation, for: .normal)
        sexBtn.isSelected = user.userSex == .boy
        addressBtn.setTitle(" \(user.address!)", for: .normal)
        
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 250 + kStatusBarHeight))
        _setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setupViews() {
        addSubview(avatarImgView)
        addSubview(authBtn)
        addSubview(sexBtn)
        addSubview(nameLabel)
        addSubview(addressBtn)
        addSubview(ageBtn)
        addSubview(starBtn)
        
        avatarImgView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(12)
            make?.width.and()?.height()?.mas_equalTo()(56)
            make?.top.mas_equalTo()(kStatusBarHeight + 40)
        }
        
        nameLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(avatarImgView.mas_right)?.offset()(8)
            make?.top.equalTo()(avatarImgView.mas_top)
        }
        
        sexBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_right)?.offset()(5)
            make?.centerY.equalTo()(nameLabel)
            make?.size.mas_equalTo()(CGSize(width: 16, height: 16))
        }
        
        authBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(sexBtn.mas_right)?.offset()(5)
            make?.right.lessThanOrEqualTo()(-10)
            make?.size.mas_equalTo()(CGSize(width: 65, height: 20))
            make?.centerY.equalTo()(nameLabel)
        }
        
        addressBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.height.mas_equalTo()(16)
            make?.right.mas_equalTo()(-10)
            make?.top.equalTo()(nameLabel.mas_bottom)?.offset()(7)
        }
        
        ageBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.top.equalTo()(addressBtn.mas_bottom)?.offset()(7)
            make?.size.mas_equalTo()(CGSize(width: 36, height: 16))
        }
        
        starBtn.mas_makeConstraints { (make) in
            make?.left.equalTo()(ageBtn.mas_right)?.offset()(5)
            make?.top.equalTo()(ageBtn.mas_top)
            make?.size.mas_equalTo()(CGSize(width: 46, height: 16))
        }
        
        let septorLine = UIView()
        septorLine.backgroundColor = RGBAColor(240, 240, 240, 1)
        addSubview(septorLine)
        septorLine.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.mas_equalTo()(0)
            make?.height.mas_equalTo()(0.8)
            make?.top.equalTo()(starBtn.mas_bottom)?.offset()(30)
        }
        
        let verSeptorWid: CGFloat = 0.8
        let itemWid = (kScreenWidth - verSeptorWid * 1) / 2.0
        for i in 0 ..< 2 {
            let item = UIButton(type: .custom)
            addSubview(item)
            item.setTitleColor(.black, for: .normal)
            item.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            item.setTitle( i == 0 ? "  我的资料" : (i == 2 ? "  会员中心" : "  系统设置"), for: .normal)
            item.setImage(UIImage(named: "ceicon00\(i+1)_1"), for: .normal)
            item.tag = 100 + i
            item.addTarget(self, action: #selector(itemClickAction(_:)), for: .touchUpInside)
            item.mas_makeConstraints { (make) in
                make?.left.mas_equalTo()((itemWid + verSeptorWid) * CGFloat(i))
                make?.top.equalTo()(septorLine.mas_bottom)?.offset()(10)
                make?.size.mas_equalTo()(CGSize(width: itemWid, height: 50))
            }
            if i < 1 {
                let varLine = UIView()
                varLine.backgroundColor = RGBAColor(240, 240, 240, 1)
                addSubview(varLine)
                varLine.mas_makeConstraints { (make) in
                    make?.left.equalTo()(item.mas_right)
                    make?.size.mas_equalTo()(CGSize(width: verSeptorWid, height: 35))
                    make?.centerY.equalTo()(item)
                }
            }
        }
        
        let line = UIView()
        addSubview(line)
        line.backgroundColor = RGBAColor(240, 240, 240, 1)
        line.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.mas_equalTo()(0)
            make?.top.equalTo()(septorLine.mas_bottom)?.offset()(70)
            make?.height.mas_equalTo()(5)
        }
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.text = "我的动态"
        addSubview(label)
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(avatarImgView.mas_left)
            make?.top.equalTo()(line.mas_bottom)
            make?.height.mas_equalTo()(35)
            make?.bottom.mas_equalTo()(0)
        }
    }
    
    @objc private func itemClickAction(_ sender: UIButton) {
        if itemBlock != nil {
            itemBlock!(sender.tag)
        }
    }
    
    lazy var avatarImgView: UIImageView = {
        let img = UIImageView()
        img.cornerRadius = 28
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var authBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        btn.size(CGSize(width: 65, height: 20))
        btn.cornerRadius = 10
        btn.setTitle("视频未认证", for: .normal)
        btn.setTitle("视频已认证", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.tag = 200
        btn.addTarget(self, action: #selector(itemClickAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var sexBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.size(CGSize(width: 16, height: 18))
        btn.cornerRadius = 8
        btn.setImage(UIImage(named: "woman001"), for: .normal)
        btn.setImage(UIImage(named: "man001"), for: .selected)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var addressBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.setImage(UIImage(named: "position002"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var ageBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.isUserInteractionEnabled = false
        btn.size(CGSize(width: 36, height: 16))
        btn.setBackgroundImage(UIImage(named: "block001_1"), for: .normal)
        return btn
    }()
    
    lazy var starBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.isUserInteractionEnabled = false
        btn.size(CGSize(width: 46, height: 16))
        btn.setBackgroundImage(UIImage(named: "block002_1"), for: .normal)
        return btn
    }()

}
