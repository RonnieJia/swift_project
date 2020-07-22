//
//  RJAnimationView.swift
//  SwiftApp

import UIKit
import JMButton


var enableKey = 100
extension JMButton {
    var isEnable: Bool {
        set {
            if newValue {
                self.isUserInteractionEnabled = true
                self.backgroundColor = RGBAColor(25, 30, 36, 1)
            } else {
                self.isUserInteractionEnabled = false
                self.backgroundColor = RGBAColor(137, 142, 146, 1)
            }
            objc_setAssociatedObject(self, &enableKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            if let res = objc_getAssociatedObject(self, &enableKey) as? Bool {
                return res
            }
            return false
        }
    }
}


public class RJAnimationView: UIView {

    @IBInspectable var animationWidth: CGFloat =  kScreenWidth-60.0
    @IBInspectable var animationHeight: CGFloat =  46
    @IBInspectable var title: String? {
        didSet {
            config.title = title
        }
    }
    @IBInspectable var isEnable: Bool = true {
        didSet {
            button?.isEnable = isEnable
        }
    }
    
    var config = JMWaveButtonConfig()
    
    var btnColor: UIColor? = RGBAColor(40, 243, 101, 1)
    
    var button: JMButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupBtn()
    }
    
    func setupBtn() {
        config.highlightedColor = .lightGray
        config.bootstrapType = .none
        config.backgroundColor = btnColor// RGBAColor(25, 30, 36, 1)
        config.title = title
        config.cornerRadius = cornerRadius
        config.titleFont = UIFont.systemFont(ofSize: 16)
        button = JMButton(frame: CGRect(x: 0, y: 0, width: animationWidth, height: animationHeight), buttonConfig: config)
        button?.backgroundColor = btnColor
        button?.layer.cornerRadius = cornerRadius
        button?.clipsToBounds = true
        self.addSubview(button!)
        button?.isEnable = isEnable
    }
    
    public func addTarget(target: Any?, action: Selector!, for event: UIControl.Event) {
        button?.addTarget(target, action: action, for: event)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
