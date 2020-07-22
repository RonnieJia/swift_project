//
//  HomeCell.swift
//  SwiftApp
//
//  Created by jia on 2020/3/20.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

typealias homeCellBlock = (_ hId: String? , _ type: Int?) -> Void

class HomeCellBtn: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView!.frame = CGRect(x: (self.width - 25) / 2.0, y: 14, width: 25, height: 22)
        self.titleLabel?.frame = CGRect(x: 0, y: 41, width: self.width, height: 15)
    }
}

public class HomeCell: UITableViewCell {
    
    var clickBlock: homeCellBlock?
    
    @IBOutlet weak var videoPlay: UIImageView!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var ageLabel: UIButton!
    
    @IBOutlet weak var starLabel: UIButton!
    
    @IBOutlet weak var sexLabel: UIButton!
    
    @IBOutlet weak var tallLabel: UIButton!
    
    @IBOutlet weak var signLabel: UIButton!
    
    @IBOutlet weak var graView: UIView!
    
    @IBOutlet weak var collectBtn: HomeCellBtn!
    
    @IBOutlet weak var chatBtn: HomeCellBtn!
    
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var naemLabel: UILabel!
    
    @IBOutlet weak var vipView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    var model: HomeModel? {
        didSet {
            videoPlay.isHidden = model?.video_state != 3
            naemLabel.text = model?.nickname
            vipView.isHidden = (model?.vip ?? 0) < 2
            if model?.vip == 2 {
                naemLabel.textColor = RGBAColor(232, 79, 83, 1)
            } else {
                naemLabel.textColor = .white
            }
            addressLabel.text = model?.city
            ageLabel.setTitle("\(model!.age ?? 0)岁", for: .normal)
            tallLabel.setTitle("\(model!.height ?? 175)cm", for: .normal)
            if kScreenWidth <= 320 {
                tallLabel.isHidden = true
            }
            sexLabel.isSelected = model?.sex == 1
            starLabel.setTitle(model?.constellation, for: .normal)
            collectBtn.isSelected = model?.follow == 1
            signLabel.setTitle("    \(model?.self_info ?? "暂无简介")    ", for: .normal)
            if let avator = model?.avatarUrl {
                iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(avator)"), placeholder: UIImage(named: "zhanwei001"))
            } else {
                iconImgView.image = UIImage(named: "zhanwei001")
            }
        }
    }
    
    static func cell(with tableView: UITableView) -> HomeCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") as?  HomeCell
               if cell == nil {
                   cell = Bundle.main.loadNibNamed("HomeCell", owner: nil, options: nil)?.first as? HomeCell
               }
        return cell!;
    }
    
    @IBAction func btnItemAction(_ sender: UIButton) {
        if clickBlock != nil {
            clickBlock!("", sender.tag)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        signLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 60)
        gradientLayer.colors = [RGBAColor(0, 0, 0, 0).cgColor, RGBAColor(0, 0, 0, 0.3).cgColor, RGBAColor(0, 0, 0, 0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.graView.layer.addSublayer(gradientLayer)
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
