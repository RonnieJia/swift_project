//
//  DetailHeaderView.swift
//  SwiftApp
//
//  Created by jia on 2020/4/14.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class DetailHeaderView: UIView {

    var followBlock: ((_ model: HomeModel, _ actionType: Int) -> Void)?
    var playVideoBlock: (() -> Void)?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        _setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: HomeModel? {
        didSet {
            videoBtn.isHidden = model?.video_state != 3
            videoLabel.isHidden = model?.video_state != 3
            nameLabel.text = model?.nickname
            vipImgView.isHidden = (model?.vip ?? 0) < 2
            if model?.vip == 2 {
                nameLabel.textColor = RGBAColor(232, 79, 83, 1)
            } else {
                nameLabel.textColor = .white
            }
            if let userid = model?.user_id {
                uidLabel.text = "UID:\(userid)"
            } else {
                uidLabel.text = nil
            }
            ageLabel.setTitle("\(model?.age ?? 0)岁", for: .normal)
            starLabel.setTitle(model?.constellation, for: .normal)
            sexLabel.isSelected = model?.sex == 1
            if let city = model?.city {
                addressLabel.isHidden = false
                if let pro = model?.province {
                    addressLabel.text = "\(pro) - \(city)"
                } else {
                    addressLabel.text = city
                }
            } else {
                addressLabel.isHidden = true
            }
            
            if let avator = model?.avatarUrl {
                iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(avator)"), placeholder: UIImage(named: "zhanwei001"))
            } else {
                iconImgView.image = UIImage(named: "zhanwei001")
            }
            signLabel.width(kScreenWidth - 35)
            signLabel.text = model?.self_info
            signLabel.sizeToFit()
            
            flowBtn.isSelected = model?.follow == 1
            
            self.height(kScreenWidth + 15 + 46 + 12 + 50 + 18 + 15 + signLabel.height + 13 + 18 + 30)
        }
    }
    
    
    lazy var videoBtn: UIButton = {
        let btn = RJImageButton(image: UIImage(named: "play001"))
        btn.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    var vipImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "vip001"))
        return imgView
    }()
    
    lazy var videoLabel: UILabel = {// 80-16
        let label = UILabel()
        label.backgroundColor = .white
        label.cornerRadius = 8
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.text = "视频已认证"
        label.textAlignment = .center
        return label
    }()
    
    lazy var uidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    lazy var iconImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "zhanwei001"))
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    lazy var ageLabel: UIButton = {// 60-23
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setBackgroundImage(UIImage(named: "block001"), for: .normal)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var starLabel: UIButton = {// 70-23
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setBackgroundImage(UIImage(named: "block002"), for: .normal)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var sexLabel: UIButton = {
        let btn = UIButton(type: .custom)
        btn.cornerRadius = 11.5
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setBackgroundImage(UIImage(named: "woman001"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "man001"), for: .selected)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var addressView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "block003"))
        imgView.contentMode = .scaleToFill
        return imgView
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var flowBtn: HomeCellBtn = {
        let btn = HomeCellBtn(type: .custom)
        btn.setImage(UIImage(named: "follow020"), for: .normal)
        btn.setImage(UIImage(named: "follow021"), for: .selected)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle("关注", for: .normal)
        btn.setTitle("取关", for: .selected)
        btn.cancelHighlighted()
        btn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var chatBtn: HomeCellBtn = {
        let btn = HomeCellBtn(type: .custom)
        btn.setImage(UIImage(named: "chat004"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("聊天", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.cancelHighlighted()
        btn.addTarget(self, action: #selector(chatAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = RGBAColor(102, 102, 102, 1)
        label.numberOfLines = 0
        return label
    }()
    
    func _setupSubViews() {
        addSubview(iconImgView)
        iconImgView.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.and()?.top()?.mas_equalTo()(0)
            make?.height.mas_equalTo()(iconImgView.mas_width)?.multipliedBy()(1)
        }
        
        addSubview(videoBtn)
        videoBtn.mas_makeConstraints { (make) in
            make?.center.equalTo()(iconImgView)
            make?.size.mas_equalTo()(CGSize(width: 52, height: 52))
        }
        
        let graView = UIView()
        graView.backgroundColor = .clear
        addSubview(graView)
        graView.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.mas_equalTo()(0)
            make?.bottom.equalTo()(iconImgView.mas_bottom)
            make?.height.mas_equalTo()(60)
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 60)
        gradientLayer.colors = [RGBAColor(0, 0, 0, 0).cgColor, RGBAColor(0, 0, 0, 0.3).cgColor, RGBAColor(0, 0, 0, 0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        graView.layer.addSublayer(gradientLayer)
        
        addSubview(nameLabel)
        nameLabel.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.bottom.equalTo()(iconImgView.mas_bottom)?.offset()(-10)
        }
        
        addSubview(vipImgView)
        vipImgView.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 20, height: 20))
            make?.left.equalTo()(nameLabel.mas_right)?.offset()(5)
            make?.centerY.equalTo()(nameLabel)
        }
        
        addSubview(videoLabel)
        videoLabel.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 80, height: 16))
            make?.left.equalTo()(vipImgView.mas_right)?.offset()(8)
            make?.centerY.equalTo()(nameLabel)
        }
        
        addSubview(uidLabel)
        uidLabel.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-15)
            make?.centerY.equalTo()(nameLabel)
        }
        
        addSubview(ageLabel)
        ageLabel.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 60, height: 23))
            make?.left.equalTo()(nameLabel.mas_left)
            make?.top.equalTo()(iconImgView.mas_bottom)?.offset()(15)
        }
        
        addSubview(starLabel)
        starLabel.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 70, height: 23))
            make?.left.equalTo()(ageLabel.mas_right)?.offset()(10)
            make?.top.equalTo()(ageLabel.mas_top)
        }
        
        addSubview(sexLabel)
        sexLabel.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 23, height: 23))
            make?.left.equalTo()(starLabel.mas_right)?.offset()(10)
            make?.top.equalTo()(ageLabel.mas_top)
        }
        
        addSubview(flowBtn)
        flowBtn.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 25, height: 70))
            make?.right.mas_equalTo()(-20)
            make?.top.equalTo()(ageLabel.mas_top)?.offset()(-10)
        }
        
        addSubview(chatBtn)
        chatBtn.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 25, height: 70))
            make?.right.equalTo()(flowBtn.mas_left)?.offset()(-30)
            make?.top.equalTo()(flowBtn.mas_top)
        }
        
        addSubview(addressView)
        addSubview(addressLabel)
        addressLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)?.offset()(12)
            make?.centerY.equalTo()(ageLabel)?.offset()(35)
            make?.right.mas_lessThanOrEqualTo()(-130)
        }
        
        addressView.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.top.equalTo()(ageLabel.mas_bottom)?.offset()(12)
            make?.height.mas_equalTo()(23)
            make?.right.equalTo()(addressLabel.mas_right)?.offset()(12)
        }
        
        let aboutL = RJLabel(font: UIFont.boldSystemFont(ofSize: 15), textColor: .black, text: "关于我")
        addSubview(aboutL)
        aboutL.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.top.equalTo()(addressView.mas_bottom)?.offset()(50)
        }
        
        addSubview(signLabel)
        signLabel.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.right.mas_equalTo()(-15)
            make?.top.equalTo()(aboutL.mas_bottom)?.offset()(15)
        }
        
        let dyLabel = RJLabel(font: UIFont.boldSystemFont(ofSize: 15), textColor: .black, text: "动态")
        addSubview(dyLabel)
        dyLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(nameLabel.mas_left)
            make?.top.equalTo()(signLabel.mas_bottom)?.offset()(20)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func followAction(_ sender: UIButton) {
        guard let user = self.model else {
            return
        }
        if followBlock != nil {
            self.followBlock!(user, 0)
        }
    }
    
    @objc func chatAction(_ sender: UIButton) {
        guard let user = self.model else {
            return
        }
        if followBlock != nil {
            self.followBlock!(user, 1)
        }
    }
    
    @IBAction func moreDynamic(_ sender: UIButton) {
        guard let user = self.model else {
            return
        }
        if followBlock != nil {
            self.followBlock!(user, 2)
        }
    }
    
    @objc func playVideo(_ sender: UIButton) {
        if self.playVideoBlock != nil {
            self.playVideoBlock!()
        }
    }
    
}
