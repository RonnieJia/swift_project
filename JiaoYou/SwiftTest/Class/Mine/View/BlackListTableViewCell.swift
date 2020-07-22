//
//  BlackListTableViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/4/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JMessage

class BlackListTableViewCell: UITableViewCell {
    var model: BlackModel? {
        didSet {
            if let url = model?.avatarUrl {
                iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(url)"), placeholder: UIImage(named: "defaultUserIcon"))
            } else {
                iconImgView.image = UIImage(named: "defaultUserIcon")
            }
            nameLabel.text = model!.nickname
            
            let date = Date(timeIntervalSince1970: model!.add_time)
            let mat = DateFormatter()
            mat.dateFormat = "MM-dd HH:mm"
            let str = mat.string(from: date)
            infoLabel.text = str
        }
    }
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var removeBlacklist: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImgView.contentMode = .scaleAspectFill
    }

    @IBAction func removeFromBlacklist(_ sender: UIButton) {
        if self.removeBlacklist != nil {
            self.removeBlacklist?()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
