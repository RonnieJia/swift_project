//
//  AnimationViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/24.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class AnimationViewController: RJViewController {

    var aniamtionView: UIView?
    
    let btn: UIButton = UIButton(type: .system)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        btn.backgroundColor = .orange
        view.addSubview(btn)
        btn.setTitle("开始", for: .normal)
        btn.frame = CGRect(x: 100, y: view.height - kNavigatioBarHeight - 90, width: view.frame.size.width - 200, height: 40)
        btn.addTarget(self, action: #selector(startAnimation), for: .touchUpInside)
        btn.addTarget(self, action: #selector(touchDownAniamtion), for: .touchDown)
        
        aniamtionView = UIView(frame: CGRect(x: 0, y: 100, width: 90, height: 90))
        aniamtionView?.backgroundColor = .red
        view.addSubview(aniamtionView!)
        
        
        
    }
    
    @objc func startAnimation() {
        positionAnimation()
        btn.layer.removeAllAnimations()
    }
    
    @objc func touchDownAniamtion() {
        scaleAnimation()
    }
    
    func positionAnimation() {
        let animation = CABasicAnimation.init(keyPath: "position")
        animation.fromValue = CGPoint(x: 0, y: 0)
        animation.toValue = CGPoint(x: 200, y: 200)
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        aniamtionView?.layer.add(animation, forKey: "positionAnimation")
    }
    
    func scaleAnimation() {
        let animation = CABasicAnimation.init(keyPath: "transform.scale")
        animation.toValue = 0.8
        animation.duration = 0.1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        btn.layer.add(animation, forKey: "scaleAnimation")
    }

}
