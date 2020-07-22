//
//  RJTabBarController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/11.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

extension UITabBar {
    func showBadge(onItem index: Int, count: Int) {
        
        if let tabbarItem = self.items?[index] {
            if count > 99 {
                tabbarItem.badgeValue = "99+"
            } else {
                tabbarItem.badgeValue = count == 0 ? nil : "\(count)"
            }
            return
        }
        
        
        
        removeBadge(on: index)
        guard count > 0 else {
            return
        }
        let bView = UIView()
        bView.tag = 8000 + index
        bView.cornerRadius = 10
        bView.backgroundColor = .red
        
        let tFrame = self.frame
        let percenterX = (CGFloat(index) + 0.56) / 5.0
        let x = CGFloat(ceilf(Float(percenterX * tFrame.width)))
        let y = CGFloat(ceilf(0.08 * Float(tFrame.height)))
        bView.frame = CGRect(x: x, y: y, width: 20, height: 20)
        
        let label = RJLabel(frame: CGRect(x: 1, y: 1, width: 18, height: 18), font: UIFont.systemFont(ofSize: 10), textColor: .white, textAlignment: .center, text: "\(count)")
        bView.addSubview(label)
        self.addSubview(bView)
        self.bringSubviewToFront(bView)
    }
    
    private func removeBadge(on index: Int) {
        let subs = self.subviews
        for subV in subs {
            if subV.tag == 8000 + index {
                subV.removeFromSuperview()
            }
        }
    }
}


extension UITabBarController {
    func showMessageBadge(_ count: Int) {
        self.tabBar.showBadge(onItem: 2, count: count)
    }
    func hideMessageBadge() {
        self.tabBar.showBadge(onItem: 2, count: 0)
    }
}

class RJTabBarController: UITabBarController, UITabBarControllerDelegate {

    static let instance = RJTabBarController()
    class var sharedInstance: RJTabBarController {
        return instance
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if CurrentUser.isVisitor() {
            let navigationController = viewController as! RJNavigationController
            if let first = navigationController.viewControllers.first {
                if first.isKind(of: MineViewController.self) || first.isKind(of: MessageViewController.self) {// || first.isKind(of: NearbyViewController.self)
                    if let nav = tabBarController.selectedViewController as? RJNavigationController {
                        if let show = nav.viewControllers.first {
                            show.showLoginAlert()
                        }
                    }
                    return false
                }
            }
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attribtes = [NSAttributedString.Key.foregroundColor:UIColor.gray, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        let selectedAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        let tabBarItem = UITabBarItem.appearance()
        tabBarItem.setTitleTextAttributes(attribtes, for: .normal)
        tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        self.setupChilden(MainViewController(), title: "首页", img: "boticon010", selectImg: "boticon011")
//        self.setupChilden(NearbyViewController(), title: "附近的人", img: "boticon030", selectImg: "boticon031")
        self.setupChilden(DynamicViewController(), title: "社交圈", img: "boticon020", selectImg: "boticon021")
        self.setupChilden(MessageViewController(), title: "消息", img: "boticon040", selectImg: "boticon041")
        let mineStoryboard = UIStoryboard(name: "Mine", bundle: nil)
        self.setupChilden(mineStoryboard.instantiateViewController(withIdentifier: "mine"), title: "我的", img: "boticon050", selectImg: "boticon051")
        
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = .black
        delegate = self
    }
    

    fileprivate func setupChilden(_ vc:UIViewController, title: String, img: String, selectImg: String) {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = UIImage(named:img)?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = UIImage(named: selectImg)?.withRenderingMode(.alwaysOriginal)
        
        let nav = RJNavigationController(rootViewController: vc)
        self.addChild(nav)
    }
}
