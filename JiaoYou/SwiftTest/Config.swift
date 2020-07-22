//
//  Config.swift
//  SwiftApp

import Foundation
import UIKit
import RJUtils_Swift
import RJNetworking_Swift
import JMButton

/*
 guxiaodong@aliyun.com     19810405James
 */

/*
苹方-简 中黑体 PingFangSC-Medium
苹方-简 中粗体 PingFangSC-Semibold
苹方-简 细体 PingFangSC-Light
苹方-简 极细体 PingFangSC-Ultralight
苹方-简 常规体 PingFangSC-Regular
苹方-简 纤细体 PingFangSC-Thin
*/

let kCJBaseUrl = "https://app.taohua45.com/"//"http://pidan.13370531053.vip/"

func ViewControllerBackgroundColor() -> UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.systemBackground
    }
    return UIColor.white
}
func ViewControllerLightGray() -> UIColor {
    if #available(iOS 13.0, *) {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.systemBackground
            }
            return RJViewColor.grayBackground.viewColor()
        }
    }
    return RJViewColor.grayBackground.viewColor()
}

let kDefaultFont = RJTextFont.defaultText.textFont()
let kDetailFont = RJTextFont.detailText.textFont()

let viewBackgroundColor = RJViewColor.grayBackground.viewColor()


let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height
let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
let kNavigatioBarHeight = kStatusBarHeight+44.0

let kDidSelectedLeftTableView = "didselectLeft"


/// 判断是否为iPhoneX
func iPhoneXType() -> Bool {
    guard #available(iOS 11.0, *) else {
        return false
    }
    return UIApplication.shared.windows[0].safeAreaInsets != UIEdgeInsets.zero
}

let safeBottomHeigt: CGFloat = {
    guard #available(iOS 11.0, *) else {
        return 0.0
    }
    return UIApplication.shared.windows[0].safeAreaInsets.bottom
}()

func safeBottom(_ bottom: CGFloat) -> CGFloat {
    return bottom + safeBottomHeigt
}

func autoSize(_ size: CGFloat) -> CGFloat {
    return size * kScreenWidth / 375.0
}


func RGBAColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}


func RJLabel(frame: CGRect? = .zero, font: UIFont? = RJTextFont.defaultText.textFont(), textColor: UIColor? = RJTextColor.textDark.textColor(), textAlignment: NSTextAlignment? = .left, text: String? = nil) -> UILabel {
    let label = UILabel()
    label.frame = frame!
    label.font = font!
    label.textColor = textColor!
    label.text = text
    label.textAlignment = textAlignment!
    return label
}


func RJImageButton(frame: CGRect? = .zero, image: UIImage? = nil, selectedImage: UIImage? = nil, backgroundImage: UIImage? = nil) -> UIButton {
    let btn = UIButton(type: .custom)
    btn.frame = frame!
    if image != nil {
        btn.setImage(image, for: .normal)
    }
    if selectedImage != nil {
        btn.setImage(selectedImage, for: .selected)
    }
    if backgroundImage != nil {
        btn.setBackgroundImage(backgroundImage, for: .normal)
    }
    return btn
}

func RJTextButton(frame: CGRect? = .zero, font: UIFont? = RJTextFont.defaultText.textFont(), textColor: UIColor? = RJTextColor.textDark.textColor(), backgroundColor: UIColor? = .white, text: String? = nil) -> UIButton {
    let btn = UIButton(type: .custom)
    if frame != nil {
        btn.frame = frame!
    }
    if font != nil {
        btn.titleLabel?.font = font!
    }
    if textColor != nil {
        btn.setTitleColor(textColor, for: .normal)
    }
    if backgroundColor != nil {
        btn.backgroundColor = backgroundColor
    }
    if text != nil {
        btn.setTitle(text!, for: .normal)
    }
    return btn
}



