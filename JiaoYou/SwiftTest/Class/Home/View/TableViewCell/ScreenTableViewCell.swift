//
//  ScreenTableViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/4/8.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import Masonry
import RJUtils_Swift

class ScreenTableViewCell: UITableViewCell {
    var indexPath = IndexPath() {
        didSet {
            if indexPath.row == 0 {
                titleLabel?.text = indexPath.section == 0 ? "星座" : "工作生活地"
                colorLayer?.colors = [RGBAColor(253, 0, 213, 1).cgColor, RGBAColor(252, 0, 167, 1).cgColor, RGBAColor(252, 0, 127, 1).cgColor]
            } else if indexPath.row == 1 {
                titleLabel?.text = indexPath.section == 0 ? "身高" : "是否认证视频"
                colorLayer?.colors = [RGBAColor(0, 197, 254, 1).cgColor, RGBAColor(0, 167, 254, 1).cgColor, RGBAColor(0, 150, 254, 1).cgColor]
            } else if (indexPath.row == 2) {
                titleLabel?.text = indexPath.section == 0 ? "年龄" : "是否认证身份"
                colorLayer?.colors = [RGBAColor(253, 213, 0, 1).cgColor, RGBAColor(253, 190, 0, 1).cgColor, RGBAColor(253, 167, 0, 1).cgColor]
            } else if (indexPath.row == 3) {
                   titleLabel?.text = indexPath.section == 0 ? "工作生活地" : "是否认证身份"
                   colorLayer?.colors = [RGBAColor(253, 0, 213, 1).cgColor, RGBAColor(252, 0, 167, 1).cgColor, RGBAColor(252, 0, 127, 1).cgColor]
            } else if (indexPath.row == 4) {
                titleLabel?.text = indexPath.section == 0 ? "是否认证视频" : "是否认证身份"
                colorLayer?.colors = [RGBAColor(0, 197, 254, 1).cgColor, RGBAColor(0, 167, 254, 1).cgColor, RGBAColor(0, 150, 254, 1).cgColor]
            }
        }
    }
    
    var colorLayer: CAGradientLayer?
    var titleLabel: UILabel?
    var infoBtn: UIButton?
    
    static func cell(with tableView: UITableView) -> ScreenTableViewCell {
        let cellIdentifier = NSStringFromClass(ScreenTableViewCell.self)
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = ScreenTableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        return cell as! ScreenTableViewCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        infoBtn = RJTextButton(font: UIFont.systemFont(ofSize: 13), textColor: .white, text: "不限")
        infoBtn?.isUserInteractionEnabled = false
        contentView.addSubview(infoBtn!)
        infoBtn?.mas_makeConstraints { make in
            make?.right.mas_equalTo()(-15)
            make?.centerY.mas_equalTo()(0)
            make?.width.mas_equalTo()(50)
            make?.height.mas_equalTo()(20)
        }
        
        colorLayer = CAGradientLayer()
        colorLayer?.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        colorLayer?.cornerRadius = 10
        colorLayer?.locations = [0.0, 0.5, 1]
        colorLayer?.startPoint = CGPoint(x: 0, y: 0)
        colorLayer?.endPoint = CGPoint(x: 1, y: 0)
        infoBtn?.layer.insertSublayer(colorLayer!, at: 0)
        
        titleLabel = RJLabel(font: RJTextFont.detailText.textFont())
        contentView.addSubview(titleLabel!)
        titleLabel?.mas_makeConstraints({ make in
            make?.left.mas_equalTo()(15)
            make?.centerY.mas_equalTo()(0)
        })
    }
    
    func setInfo(_ info: String) {
        infoBtn?.setTitle(info, for: .normal)
        if info == "不限" || info == "是" || info == "否" {
            infoBtn?.mas_remakeConstraints({ (make) in
                make?.right.mas_equalTo()(-15)
                make?.centerY.mas_equalTo()(0)
                make?.width.mas_equalTo()(50)
                make?.height.mas_equalTo()(20)
            })
            colorLayer?.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        } else {
            infoBtn?.mas_remakeConstraints({ (make) in
                make?.right.mas_equalTo()(-15)
                make?.centerY.mas_equalTo()(0)
                make?.width.mas_equalTo()(80)
                make?.height.mas_equalTo()(20)
            })
            colorLayer?.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
