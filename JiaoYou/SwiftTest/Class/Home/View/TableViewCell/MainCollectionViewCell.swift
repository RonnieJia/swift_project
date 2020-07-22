//
//  MainCollectionViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/5/28.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    typealias mainCellBlock = (_ hId: String? , _ type: Int?) -> Void
    var clickBlock: homeCellBlock?
    
    
    var model: HomeModel? {
        didSet {
            authImgVIew.isHidden = model?.video_state != 3
            nameLabel.text = model?.nickname
            if model?.vip == 2 {
                nameLabel.textColor = RGBAColor(232, 79, 83, 1)
            } else {
                nameLabel.textColor = .white
            }
            addressLabel.text = model?.city
            let info = "\(model!.age ?? 0)岁·\(model!.constellation ?? "")·\(model!.height ?? 175)cm"
            infoLabel.text = info
            followBtn.isSelected = model?.follow == 1
            signLabel.text = "\(model?.self_info ?? "暂无简介")"
            if let avator = model?.avatarUrl {
                avatarImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(avator)"), placeholder: UIImage(named: "zhanwei001"))
            } else {
                avatarImgView.image = UIImage(named: "zhanwei001")
            }
        }
    }
    
    
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var authImgVIew: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    
    @IBAction func chatAction(_ sender: UIButton) {
        if clickBlock != nil {
            clickBlock!("", sender.tag)
        }
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        if clickBlock != nil {
            clickBlock!("", sender.tag)
        }
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.width, height: 70)
        gradientLayer.colors = [RGBAColor(0, 0, 0, 0).cgColor, RGBAColor(0, 0, 0, 0.3).cgColor, RGBAColor(0, 0, 0, 0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.containerView.layer.addSublayer(gradientLayer)
    }

}
