//
//  VistorTableViewCell.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/5.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class VistorTableViewCell: UITableViewCell {

    var model: VistorModel? {
        didSet {
            if let url = model?.avatarUrl {
                iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(url)"), placeholder: UIImage(named: "defaultUserIcon"))
            } else {
                iconImgView.image = UIImage(named: "defaultUserIcon")
            }
            nameLabel.text = model!.nickname
            sexBtn.isSelected = model!.sex == 1
            let date = Date(timeIntervalSince1970: model!.add_time)
            let mat = DateFormatter()
            mat.dateFormat = "MM-dd HH:mm"
            let str = mat.string(from: date)
            dateLabel.text = str
        }
    }
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sexBtn: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
