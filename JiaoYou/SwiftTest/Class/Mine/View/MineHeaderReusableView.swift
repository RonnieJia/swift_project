//
//  MineHeaderReusableView.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/5/5.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class MineHeaderReusableView: UICollectionReusableView {
    
    var setBlock: (() -> ())?
    var moreBlock: (() -> ())?
    var itemBlock: ((_ index: Int) -> ())?
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageBtn: UIButton!
    
    @IBOutlet weak var starBtn: UIButton!
    
    @IBOutlet weak var sexBtn: UIButton!
    
    @IBOutlet weak var addressBtn: UIButton!
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var dyLabel: UILabel!
    
    func display(_ shows: Bool = false) {
        let user = CurrentUser.sharedInstance
        if user.avatarUrl != nil {
            iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(user.avatarUrl!)"), placeholder: UIImage(named: "defaultUserIcon"))
        }
        moreBtn.isHidden = !shows
        dyLabel.isHidden = !shows
        nameLabel.text = user.nickname
        ageBtn.setTitle("\(user.age)岁", for: .normal)
        starBtn.setTitle(user.constellation, for: .normal)
        sexBtn.isSelected = user.userSex == .boy
        addressBtn.setTitle(user.address, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addressBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    @IBAction func itemAction(_ sender: UIButton) {
        if self.itemBlock != nil {
            self.itemBlock!(sender.tag)
        }
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        if self.moreBlock != nil {
            self.moreBlock!()
        }
    }
    
    @IBAction func settingAction(_ sender: UIButton) {
        if self.setBlock != nil {
            self.setBlock!()
        }
    }
}
