//
//  RJUtils.swift

import Foundation
import UIKit
import NVActivityIndicatorView
import MBProgressHUD



public enum RJTextFont {
    case navigationTitle
    case defaultText
    case detailText
    
    public func textFont() -> UIFont {
        switch self {
        case .navigationTitle:
            return UIFont.systemFont(ofSize: 18)
        case .defaultText:
            return UIFont.systemFont(ofSize: 14)
        case .detailText:
            return UIFont.systemFont(ofSize: 12)
        }
    }
}

public enum RJViewColor {
    case grayBackground
    case septorLine
    
    public func viewColor() -> UIColor {
        switch self {
        case .grayBackground:
            return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        case .septorLine:
            if #available(iOS 13.0, *) {
                return UIColor.separator
            } else {
                return UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
            }
        }
    }
}
public enum RJTextColor {
    case textGray
    case textDark
    case placeholder
    
    public func textColor() -> UIColor {
        switch self {
        case .textGray:
            return UIColor.lightText
        case .textDark:
            return UIColor.darkText
        case .placeholder:
            if #available(iOS 13.0, *) {
                return UIColor.placeholderText
            } else {
                return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            }
        }
    }
}



public let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
public let kNavigatioBarHeight = kStatusBarHeight+44.0
public let kTabbarHeight = UITabBar.appearance().frame.height

public extension UIViewController {
    func RJ_showMessage(message: String) {
        self.view.RJ_showMessage(message: message)
    }
    
    func showProgressHUD(type:NVActivityIndicatorType? = NVActivityIndicatorView.DEFAULT_TYPE, message: String? = nil) {
        self.view.RJ_showProgressHUD(type: type, message: message)
    }
    
    func hideProgressHUD(message: String? = nil)  {
        self.view.RJ_hideProgressHUD(message: message)
    }
}

public extension UIView {
    func RJ_showMessage(message msg: String, textColor: UIColor? = .white, backgroundColor: UIColor? = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)) {
        let messageHud = MBProgressHUD.showAdded(to: self, animated: true)
        messageHud.mode = .text
        messageHud.label.text = msg
        messageHud.label.textColor = textColor
        messageHud.bezelView.backgroundColor = backgroundColor
        messageHud.hide(animated: true, afterDelay: 0.8)
    }
    
    func  RJ_showProgressHUD(type:NVActivityIndicatorType? = NVActivityIndicatorView.DEFAULT_TYPE, message: String? = nil) {
        let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: type)
        activityIndicatorView.startAnimating()
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.bezelView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        hud.mode = .customView
        hud.customView = activityIndicatorView
        hud.label.text = message
        hud.label.textColor = .white
    }
    
    func RJ_hideProgressHUD(message msg: String? = nil) {
        guard let hud = MBProgressHUD(for: self) else { return }
        if let activiyView: NVActivityIndicatorView = hud.customView as? NVActivityIndicatorView {
            activiyView.stopAnimating()
        }
        if let message = msg {
            hud.mode = .text
            hud.label.text = message
            hud.label.textColor = .white
            hud.hide(animated: true, afterDelay: 0.8)
        } else {
            hud.hide(animated: true)
        }
    }
}

/// UIView  frame
public extension UIView {
    var x: CGFloat {
        return self.frame.minX
    }
    
    func x(_ x: CGFloat) {
        var rect = self.frame
        rect.origin.x = x
        self.frame = rect
    }
    
    var y: CGFloat {
        return self.frame.minY
    }
    
    func y(_ y: CGFloat) {
        var rect = self.frame
        rect.origin.y = y
        self.frame = rect
    }
    
    var right: CGFloat {
        return self.frame.maxX
    }
    
    func right(_ r: CGFloat) {
        var rect = self.frame
        rect.origin.x = r - rect.size.width
        self.frame = rect
    }
    
    var bottom: CGFloat {
        return self.frame.maxY
    }
    
    func bottom(_ b: CGFloat) {
        var rect = self.frame
        rect.origin.y = b - rect.size.height
        self.frame = rect
    }
    
    var width: CGFloat {
        return self.frame.width
    }
    
    func width(_ w: CGFloat) {
        var rect = self.frame
        rect.size.width = w
        self.frame = rect
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    func height(_ h: CGFloat) {
        var rect = self.frame
        rect.size.height = h
        self.frame = rect
    }
    
    var centerX: CGFloat {
        return self.center.x
    }
    
    func centerX(_ centerX: CGFloat) {
        var cen = self.center
        cen.x = centerX
        self.center = cen
    }
    
    var centerY: CGFloat {
        return self.center.y
    }
    
    func centerY(_ centerY: CGFloat) {
        var cen = self.center
        cen.y = centerY
        self.center = cen
    }
    
    var size: CGSize {
        return self.frame.size
    }
    
    func size(_ size:CGSize) -> Void {
        var frame = self.frame
        frame.size = size
        self.frame = frame;
    }
}
