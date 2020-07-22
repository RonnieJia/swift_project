//
//  JChatView.swift
//  SwiftApp
//
//  Created by jia on 2020/4/24.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

public protocol JChatViewDataSource: class {
    
    func numberOfItems(in chatView: JChatView)
    
    func chatView(_ chatView: JChatView, itemAtIndexPath: IndexPath)
}

@objc open class JChatView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
