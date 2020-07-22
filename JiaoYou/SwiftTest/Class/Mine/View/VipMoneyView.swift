//
//  VipMoneyView.swift
//  SwiftApp
//
//  Created by jia on 2020/5/7.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class VipButton: UIButton {
    var timeLabel: UILabel?
    var moneyLabel: UILabel?
    
    var productId: String?
    
    class func item(_ index: Int) -> VipButton {
        let btn = VipButton(type: .custom)
        
        btn.timeLabel = RJLabel(font: UIFont(name: "PingFangSC-Medium", size: 18), textAlignment: .center)
        btn.addSubview(btn.timeLabel!)
        
        btn.moneyLabel = RJLabel(font: UIFont(name: "PingFangSC-Medium", size: 24), textAlignment: .center)
        btn.addSubview(btn.moneyLabel!)
        
        btn.timeLabel?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(5)
            make?.right.mas_equalTo()(-5)
            make?.bottom.mas_equalTo()(-76)
        })
        
        btn.moneyLabel?.mas_makeConstraints({ (make) in
            make?.left.mas_equalTo()(5)
            make?.right.mas_equalTo()(-5)
            make?.centerY.mas_equalTo()(0)
        })
        
        var timeStr = "2个月"
        var money = "￥98"
        btn.productId = "com.tongyi.taohua98"
        if index == 1 {
            timeStr = ""//"1年"
            money = "￥388"
            btn.productId = "com.tongyi.taohua388"
        } else if index == 2 {
            btn.productId = "com.tongyi.taohua138"
            timeStr = "3个月"
            money = "￥138"
        }
//        let att = NSMutableAttributedString(string: timeStr)
//        att.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "PingFangSC-Medium", size: 22), range: NSRange(location: 0, length: 1))
//        btn.timeLabel?.attributedText = att
        btn.moneyLabel?.text = money
        btn.borderColor = .red
        
        return btn
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.borderWidth = 1.6
            } else {
                self.borderWidth = 0
            }
        }
    }
}

class VipMoneyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupViews()
    }
    
    private var selectBtn: VipButton?
    private var payBlock: ((_ type: Int, _ product: String) -> Void)?
    
    func _setupViews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        var wid: CGFloat = 345
        if self.width < 375 {
            wid = self.width - 30
        }
        let whiView = UIView(frame: CGRect(x: 0, y: 0, width: wid, height: wid * 203 / 343 + 260))
        whiView.backgroundColor = .white
        self.addSubview(whiView)
        whiView.cornerRadius = 14
        whiView.addGestureRecognizer(UITapGestureRecognizer())
        whiView.center = CGPoint(x: kScreenWidth/2, y: kScreenHeight/2)
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: wid, height: wid * 203 / 343))
        whiView.addSubview(imgView)
        imgView.image = UIImage(named: "viptitle")
        
        let view2 = UIView(frame: CGRect(x: 10, y: 25 + imgView.bottom, width: whiView.width - 20, height: 140))
        whiView.addSubview(view2)
        view2.backgroundColor = ViewControllerLightGray()
        view2.cornerRadius = 10
        
        for i in 1 ..< 2 {
            let item = VipButton.item(i)
            item.frame = CGRect(x: 10, y: 0, width: view2.width - 20, height: 140)
            view2.addSubview(item)
            item.addTarget(self, action: #selector(itemAction(_:)), for: .touchUpInside)
            item.tag = i
            if i == 1 {
                item.isSelected = true
                selectBtn = item
                let label = RJLabel(frame: CGRect(x: 0, y: imgView.bottom + 12, width: 75, height: 25), font: UIFont.systemFont(ofSize: 12), textColor: .white, textAlignment: .center, text: "限时特惠")
                label.backgroundColor = RGBAColor(246, 95, 50, 1)
                label.centerX(whiView.width / 2)
                whiView.addSubview(label)
            }
        }
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 20, y: view2.bottom + 25, width: whiView.width - 40, height: 46)
        btn.cornerRadius = 23
        btn.setTitle("立即获取", for: .normal)
        btn.backgroundColor = RGBAColor(254, 111, 0, 1)
        btn.setTitleColor(.white, for: .normal)
        whiView.addSubview(btn)
        btn.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        self.addGestureRecognizer(tap)
    }
    
    @objc func itemAction(_ sender: VipButton) {
        guard !sender.isSelected else {
            return
        }
        if selectBtn != nil {
            selectBtn?.isSelected = false
        }
        selectBtn = sender
        sender.isSelected = true
    }
    
    @objc func actionClick() {
        self.hideSelf()
        if selectBtn == nil {
            return
        }
        if self.payBlock != nil {
            if let tag = selectBtn?.tag, let pro = selectBtn?.productId {
                self.payBlock!(tag, pro)
            }
        }
    }
    
    static func show(_ vipBlock: @escaping (_ type: Int, _ product: String) -> Void) {
        let vipView = VipMoneyView(frame: UIScreen.main.bounds)
        vipView.payBlock = vipBlock
        UIApplication.shared.keyWindow?.addSubview(vipView)
    }
    
    @objc func hideSelf() {
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
