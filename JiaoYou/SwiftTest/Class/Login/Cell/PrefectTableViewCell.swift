//
//  PrefectTableViewCell.swift
//  SwiftApp

import UIKit
import RJUtils_Swift

class PrefectTableViewCell: UITableViewCell {
    var titleL: UILabel?
    var infoL: UIButton?
    var iconImg: UIImageView?
    
    var index: NSInteger? {
        didSet {
            infoL?.isHidden = false
            iconImg?.isHidden = true
        }
    }
    
    static func cell(with tableView: UITableView) -> PrefectTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "prefectCell")
        if cell == nil {
            cell = PrefectTableViewCell.init(style: .default, reuseIdentifier: "prefectCell")
        }
        return cell as! PrefectTableViewCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        titleL = RJLabel(font: RJTextFont.detailText.textFont(), textColor: RJTextColor.textDark.textColor())
        contentView.addSubview(titleL!)
        titleL?.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(15)
            make?.centerY.mas_equalTo()(0)
        }
        
        infoL = RJTextButton(font: RJTextFont.detailText.textFont(), textColor: RJTextColor.textDark.textColor())
        contentView.addSubview(infoL!)
        infoL?.contentHorizontalAlignment = .right
        infoL?.isEnabled = false
        infoL?.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(-10)
            make?.centerY.mas_equalTo()(0)
        })
        
        iconImg = UIImageView()
        contentView.addSubview(iconImg!)
        iconImg?.cornerRadius = 18.0
        iconImg?.backgroundColor = viewBackgroundColor
        iconImg?.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(-15)
            make?.width.and()?.height()?.mas_equalTo()(36)
            make?.centerY.mas_equalTo()(0)
        })
        
        accessoryType = .disclosureIndicator
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
