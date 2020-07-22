//
//  RJNavigationController.swift
//  SwiftApp
//
//  Created by jia on 2020/3/11.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class RJNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count>0 {
            viewController.hidesBottomBarWhenPushed=true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
