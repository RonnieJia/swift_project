//
//  UIView+Rect.swift
//  SwiftApp

import UIKit
import MBProgressHUD
import NVActivityIndicatorView
import JMButton



public extension UIView {
    func showMessage(message: String) {
        let messageHud = MBProgressHUD.showAdded(to: self, animated: true)
        messageHud.mode = .text
        messageHud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        messageHud.label.text = message
        messageHud.label.textColor = .white
        messageHud.hide(animated: true, afterDelay: 0.8)
    }
    
    func showProgressHUD(type:NVActivityIndicatorType? = NVActivityIndicatorView.DEFAULT_TYPE, message: String? = nil) {
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
    
    func hideProgressHUD(message: String? = nil)  {
        guard let hud = MBProgressHUD(for: self) else { return }
        if let activiyView: NVActivityIndicatorView = hud.customView as? NVActivityIndicatorView {
            activiyView.stopAnimating()
        }
        if let message = message {
            hud.mode = .text
            hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            hud.label.text = message
            hud.label.textColor = .white
            hud.hide(animated: true, afterDelay: 0.8)
        } else {
            hud.hide(animated: true)
        }
    }
    
    func getController() -> UIViewController? {
        let responder: UIResponder = self
        while let nextResponder = responder.next {
            if nextResponder.isKind(of: UIViewController.self) {
                return nextResponder as? UIViewController
            }
        }
        return nil
    }
}

/// 取消button点击效果
extension UIButton {
    func cancelHighlighted() {
        self.addTarget(self, action: #selector(_cancelHighlighted), for: .allEvents)
    }
    
    @objc private func _cancelHighlighted() {
        self.isHighlighted = false
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
}


extension NSObject {
    var className: String {
        get{
            let name =  type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".").last!;
            }else{
                return name;
            }
        }
    }
}

