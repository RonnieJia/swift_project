//
//  DynamicDetailHeader.swift
//  SwiftApp
//
//  Created by jia on 2020/4/29.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import SDCycleScrollView

class DynamicDetailHeader: UIView {

    var jubaoBlock: (() -> ())?
    var chatBlock: (() -> ())?
    var followBlock: (() -> ())?
    var likeBlock: (() -> ())?
    
    var model: SocietyModel? {
        didSet {
            avatorImgView?.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(model!.avatarUrl)"), placeholder: UIImage(named: "face002"))
            nameLabel?.text = model!.nickname
            ageBtn?.setTitle("\(model!.age)岁", for: .normal)
            starBtn?.setTitle(model?.constellation, for: .normal)
            vipImgView?.isHidden = model?.vip != 2
            nameLabel?.mas_updateConstraints({ (make) in
                if model?.vip == 2 {
                    make?.left.equalTo()(vipImgView?.mas_right)?.offset()(6)
                } else {
                    make?.left.equalTo()(vipImgView?.mas_left)
                }
            })
            followBtn?.isSelected = model?.follow == 1
            comLabel?.text = "\(model!.com_num)评论"
            likeLabel?.text = "\(model!.like_num)赞"
            followBtn?.isHidden = model!.user_id == CurrentUser.sharedInstance.userId
            likeBtn?.isSelected = model?.like == 1
            
            var images: [String] = []
            if let imgs = model?.show_img, imgs.count > 0 {
                for path in imgs {
                    images.append("\(kCJBaseUrl)\(path)")
                }
            }
            cycleView!.imageURLStringsGroup = images
        }
    }
    
    var avatorImgView: UIImageView?
    
    var vipImgView: UIImageView?
    
    var followBtn: UIButton?
    
    var nameLabel: UILabel?
    
    var ageBtn: UIButton?
    
    var starBtn: UIButton?
    
    var cycleView: SDCycleScrollView?
    
    var likeBtn: UIButton?
    
    var comLabel: UILabel?
    
    var likeLabel: UILabel?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth + 170))
        _setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupViews()
    }
    
    func _setupViews() {
        backgroundColor = .white
        
        avatorImgView = UIImageView()
        avatorImgView?.cornerRadius = 19
        avatorImgView?.clipsToBounds = true
        addSubview(avatorImgView!)
        avatorImgView?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(20)
            make?.width.and()?.height()?.mas_equalTo()(38)
            make?.top.mas_equalTo()(15)
        })
        
        vipImgView = UIImageView()
        vipImgView?.image = UIImage(named: "vip001")
        addSubview(vipImgView!)
        vipImgView?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(avatorImgView?.mas_right)?.offset()(15)
            make?.width.and()?.height()?.mas_equalTo()(20)
            make?.top.mas_equalTo()(10)
        })
        
        followBtn = RJTextButton(font: UIFont.systemFont(ofSize: 12), textColor: UIColor.darkGray, text: "关注")
        followBtn?.setTitle("已关注", for: .selected)
        followBtn?.setTitleColor(UIColor.lightGray, for: .selected)
        addSubview(followBtn!)
        followBtn?.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(-20)
            make?.width.mas_equalTo()(52)
            make?.height.mas_equalTo()(26)
            make?.centerY.equalTo()(avatorImgView?.mas_centerY)
        })
        followBtn?.cornerRadius = 13
        followBtn?.clipsToBounds = true
        followBtn?.borderWidth = 0.8
        followBtn?.borderColor = UIColor.darkGray
        followBtn?.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        
        nameLabel = RJLabel()
        addSubview(nameLabel!)
        nameLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(vipImgView?.mas_right)?.offset()(6)
            make?.right.equalTo()(followBtn?.mas_left)?.offset()(-10)
            make?.top.equalTo()(vipImgView?.mas_top)
            make?.height.mas_equalTo()(20)
        })
        
        ageBtn = RJTextButton(textColor: UIColor.white)
        addSubview(ageBtn!)
        ageBtn?.setBackgroundImage(UIImage(named: "block001"), for: .normal)
        ageBtn?.isUserInteractionEnabled = false
        ageBtn?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(vipImgView?.mas_left)
            make?.top.equalTo()(vipImgView?.mas_bottom)?.offset()(5)
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(23)
        })
        
        starBtn = RJTextButton(textColor: UIColor.white)
        addSubview(starBtn!)
        starBtn?.setBackgroundImage(UIImage(named: "block002"), for: .normal)
        starBtn?.isUserInteractionEnabled = false
        starBtn?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(ageBtn?.mas_right)?.offset()(10)
            make?.top.equalTo()(ageBtn?.mas_top)
            make?.width.mas_equalTo()(70)
            make?.height.mas_equalTo()(23)
        })
        
        cycleView = SDCycleScrollView(frame: CGRect(x: 0, y: 52, width: kScreenWidth, height: kScreenWidth), delegate: self, placeholderImage: UIImage(named: "zhanwei001"))
        addSubview(cycleView!)
        cycleView?.mas_makeConstraints({ (make) in
            make?.left.and()?.right()?.mas_equalTo()(0)
            make?.height.mas_equalTo()(kScreenWidth)
            make?.top.equalTo()(avatorImgView?.mas_bottom)?.offset()(15)
        })
        
        let msgBtn = RJImageButton(image: UIImage(named: "chat001"))
        addSubview(msgBtn)
        msgBtn.mas_makeConstraints { (make) in
            make?.width.and()?.height()?.mas_equalTo()(21)
            make?.left.mas_equalTo()(20)
            make?.top.equalTo()(cycleView?.mas_bottom)?.offset()(15)
        }
        msgBtn.addTarget(self, action: #selector(chatAction), for: .touchUpInside)
        
        likeBtn = RJImageButton(image: UIImage(named: "nice010-1"))
        likeBtn?.setImage(UIImage(named: "nice011-1"), for: .selected)
        addSubview(likeBtn!)
        likeBtn?.mas_makeConstraints { (make) in
            make?.width.and()?.height()?.mas_equalTo()(24)
            make?.left.equalTo()(msgBtn.mas_right)?.offset()(25)
            make?.centerY.equalTo()(msgBtn.mas_centerY)
        }
        likeBtn?.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        
        let moreBtm = RJImageButton(image: UIImage(named: "more003"))
        addSubview(moreBtm)
        moreBtm.mas_makeConstraints { (make) in
            make?.width.and()?.height()?.mas_equalTo()(25)
            make?.right.mas_equalTo()(-15)
            make?.centerY.equalTo()(msgBtn.mas_centerY)
        }
        moreBtm.addTarget(self, action: #selector(jubaoAction), for: .touchUpInside)
        
        let view = UIView()
        addSubview(view)
        view.backgroundColor = ViewControllerLightGray()
        view.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.mas_equalTo()(0)
            make?.top.equalTo()(msgBtn.mas_bottom)?.offset()(15)
            make?.height.mas_equalTo()(10)
        }
        
        comLabel = RJLabel()
        addSubview(comLabel!)
        comLabel?.mas_makeConstraints({ (make) in
            make?.left.equalTo()(msgBtn.mas_left)
            make?.centerY.equalTo()(view.mas_bottom)?.offset()(20)
        })
        
        likeLabel = RJLabel()
        likeLabel?.textAlignment = .right
        addSubview(likeLabel!)
        likeLabel?.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(-20)
            make?.centerY.equalTo()(view.mas_bottom)?.offset()(20)
        })
    }
    
    @objc func jubaoAction() {
        if self.jubaoBlock != nil {
            self.jubaoBlock!()
        }
    }
    
    @objc func chatAction() {
        if self.chatBlock != nil {
            self.chatBlock!()
        }
    }
    @objc func followAction() {
        if self.followBlock != nil {
            self.followBlock!()
        }
    }
    @objc func likeAction() {
        if self.likeBlock != nil {
            self.likeBlock!()
        }
    }
}

extension DynamicDetailHeader: SDCycleScrollViewDelegate {
    
}

