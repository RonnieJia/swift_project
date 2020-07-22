//
//  RecommendTableViewCell.swift
//  SwiftApp
//
//  Created by Ronnie Jia on 2020/4/14.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JXPhotoBrowser
import SDCycleScrollView

class RecommendTableViewCell: UITableViewCell {

    var model: SocietyModel? {
        didSet {
            iconImgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(model!.avatarUrl)"), placeholder: UIImage(named: "defaultUserIcon"))
            nameLabel.text = model?.nickname
            ageBtn.setTitle("\(model!.age)岁", for: .normal)
            starBtn.setTitle(model?.constellation, for: .normal)
            sexBtn.isSelected = model?.sex == 1
            attentionBtn.isSelected = model?.follow == 1
//            vipFlag.isHidden = model?.vip != 2
            if model?.vip == 2 {
                nameLabel.textColor = RGBAColor(232, 79, 83, 1)
            } else {
                nameLabel.textColor = .black
            }
            commenBtn.setTitle(" \(model!.com_num)", for: .normal)
            attentionBtn.setTitle(" \(model!.like_num)", for: .normal)
            attentionBtn.isSelected = model?.like == 1
            
            var images: [String] = []
            if let imgs = model?.show_img, imgs.count > 0 {
                for path in imgs {
                    images.append("\(kCJBaseUrl)\(path)")
                }
            }
            removeAllSubView()
            if images.count > 0 {
                var wid: CGFloat = autoSize(200)
                var count = 1
                if images.count == 2 {
                    count = 2
                    wid = autoSize(140)
                    self.imgContentHeight.constant = autoSize(140)
                } else if images.count > 2 {
                    wid = (kScreenWidth - 30) / 3.0
                    count = images.count > 6 ? 6 : images.count
                    self.imgContentHeight.constant = wid * (count > 3 ? 2.0 : 1.0) + (count > 3 ? 5.0 : 0)
                } else {
                    self.imgContentHeight.constant = autoSize(200)
                }
                for i in 0 ..< count {
                    let imgView = UIImageView(frame: CGRect(x: (wid + 5) * CGFloat(i % 3) + 10, y: (wid + 5) * CGFloat(i / 3), width: wid, height: wid))
                    imgView.contentMode = UIView.ContentMode.scaleAspectFill
                    imgView.layer.cornerRadius = 4
                    imgView.clipsToBounds = true
                    imgContentView.addSubview(imgView)
                    imgView.tag = 100 + i
                    imgView.isUserInteractionEnabled = true
                    imgView.kf.setImage(with: URL(string: images[i]), placeholder: UIImage(named: "zhanwei001"))
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(showImgAction(_:)))
                    imgView.addGestureRecognizer(tap)
                }
            } else {
                self.imgContentHeight.constant = 0
            }
        }
    }
    
    private func removeAllSubView() {
        let views = self.imgContentView.subviews
        for view in views {
            view.removeFromSuperview()
        }
    }
    
    var jubaoBlock: ((_ model: SocietyModel) -> Void)?
    var followBlock: ((_ model: SocietyModel) -> Void)?
    var likeBlock: ((_ model: SocietyModel) -> Void)?

    @IBOutlet weak var imgContentHeight: NSLayoutConstraint!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var vipFlag: UIImageView!
    
    @IBOutlet weak var attentionBtn: UIButton!
    
    @IBOutlet weak var ageBtn: UIButton!
    
    @IBOutlet weak var starBtn: UIButton!
    
    @IBOutlet weak var sexBtn: UIButton!
    
    @IBOutlet weak var commenBtn: UIButton!
    
    static func cell(with tableView: UITableView) -> RecommendTableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RecommendTableViewCell") as?  RecommendTableViewCell
               if cell == nil {
                   cell = Bundle.main.loadNibNamed("RecommendTableViewCell", owner: nil, options: nil)?.first as? RecommendTableViewCell
               }
        return cell!;
    }
    
    @IBAction func followAction(_ sender: UIButton) {
        if self.followBlock != nil {
            self.followBlock!(model!)
        }
    }
    @IBAction func jubaoAction(_ sender: UIButton) {
        if self.jubaoBlock != nil {
            self.jubaoBlock!(model!)
        }
    }
    @IBAction func likeAction(_ sender: UIButton) {
        if self.likeBlock != nil {
            self.likeBlock!(model!)
        }
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

extension RecommendTableViewCell {
    @objc private func showImgAction(_ tap: UITapGestureRecognizer) {
        guard let count = self.model?.show_img.count, count > 0 else {
            return
        }
        let imgIndex = (tap.view?.tag ?? 100) - 100
        var images: [String] = []
        if let imgs = model?.show_img, imgs.count > 0 {
            for path in imgs {
                images.append("\(kCJBaseUrl)\(path)")
            }
        }
        
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return images.count
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.kf.setImage(with: URL(string: images[context.index]), placeholder: UIImage(named: "zhanwei001"))
        }
        let pageIndicator = JXPhotoBrowserNumberPageIndicator(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        browser.pageIndicator = pageIndicator
        browser.view.addSubview(pageIndicator)
        browser.pageIndex = imgIndex
        browser.reloadData()
        browser.show()
    }
    
}


