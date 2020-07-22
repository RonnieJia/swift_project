//
//  ImageListTableViewCell.swift
//  SwiftApp
//
//  Created by 辉贾 on 2020/4/28.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JXPhotoBrowser

class ImageListTableViewCell: UITableViewCell {

    var model: SocietyModel? {
        didSet {
            dateLabel.text = "\(model!.times)天前"
            likeBtn.setTitle("赞\(model!.like_num)", for: .normal)
            likeBtn.isSelected = model?.like == 1
            EvaBtn.setTitle("评论\(model!.com_num)", for: .normal)
            
            removeAllSubView()
            if let imgsArr = model?.show_img, imgsArr.count > 0 {
                var wid: CGFloat = autoSize(200)
                var count = 1
                if imgsArr.count == 2 {
                    count = 2
                    wid = autoSize(140)
                } else if imgsArr.count > 2 {
                    wid = (kScreenWidth - 35 - 40) / 3.0
                    count = imgsArr.count > 6 ? 6 : imgsArr.count
                }
                for i in 0 ..< count {
                    let imgView = UIImageView(frame: CGRect(x: (wid + 10) * CGFloat(i % 3), y: (wid + 10) * CGFloat(i / 3), width: wid, height: wid))
                    imgView.contentMode = UIView.ContentMode.scaleAspectFill
                    imgView.layer.cornerRadius = 4
                    imgView.clipsToBounds = true
                    imgContentView.addSubview(imgView)
                    imgView.tag = 100 + i
                    imgView.isUserInteractionEnabled = true
                    imgView.kf.setImage(with: URL(string: "\(kCJBaseUrl)\(imgsArr[i])"), placeholder: UIImage(named: "zhanwei001"))
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(showImgAction(_:)))
                    imgView.addGestureRecognizer(tap)
                }
            }
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imgContentView: UIView!
    
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var EvaBtn: UIButton!
    
    private func removeAllSubView() {
        let views = self.imgContentView.subviews
        for view in views {
            view.removeFromSuperview()
        }
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        EvaBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
