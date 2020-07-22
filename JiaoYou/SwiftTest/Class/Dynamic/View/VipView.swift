//
//  VipView.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/4/29.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

enum VipType {
    case Issue
    case Sort
}

class VipView: UIView {
    
    static let shared = VipView()
    
    private var vipActionblock: (() -> Void)?
    var textView: UIView?
    var textLabel: UILabel?
    
    init(_ type: VipType = .Issue) {
        super.init(frame: UIScreen.main.bounds)
        _setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setupViews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 303, height: 367))
        self.addSubview(imgView)
        imgView.image = UIImage(named: "vip002")
        imgView.center = CGPoint(x: kScreenWidth/2, y: kScreenHeight/2)
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer())
        
        let btn = RJAnimationView(frame: CGRect(x: 45, y: imgView.height - 20 - 46, width: imgView.width - 90, height: 46))
        btn.btnColor = RGBAColor(40, 243, 101, 1)
        btn.cornerRadius = 23
        btn.animationWidth = imgView.width - 90
        btn.title = "立即升级"
        btn.setupBtn()
        imgView.addSubview(btn)
        btn.addTarget(target: self, action: #selector(actionClick), for: .touchUpInside)
        
//        textView = UIView(frame: CGRect(x: 0, y: 250, width: imgView.width, height: 46))
//        textView?.backgroundColor = .white
//        imgView.addSubview(textView!)
//        textLabel = RJLabel(frame: CGRect(x: 10, y: 0, width: textView!.width - 20, height: 46), font: UIFont.systemFont(ofSize: 12), textColor: UIColor.lightGray, textAlignment: .center, text: "")
//        textView?.addSubview(textLabel!)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        self.addGestureRecognizer(tap)
    }
    
    @objc func actionClick() {
        self.hideSelf()
        if self.vipActionblock != nil {
            self.vipActionblock!()
        }
    }
    
    static func show(_ vipBlock: @escaping () -> Void) {
        let vipView = VipView.shared
        vipView.vipActionblock = vipBlock
        UIApplication.shared.keyWindow?.addSubview(vipView)
    }
    
    @objc func hideSelf() {
        self.removeFromSuperview()
    }
    /*a perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
