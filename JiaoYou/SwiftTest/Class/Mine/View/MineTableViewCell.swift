//
//  MineTableViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/6/2.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JXPhotoBrowser

class MineTableViewCell: UITableViewCell {

    var niceBlock: (() -> ())?
    
    var index: NSInteger?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var imgContentHeight: NSLayoutConstraint!
    @IBOutlet weak var commonBtn: UIButton!
    @IBOutlet weak var niceBtn: UIButton!
    
    
   var model: SocietyModel? {
        didSet {
            dateLabel.text = "\(model!.times)天前"
            niceBtn.setTitle(" \(model!.like_num)", for: .normal)
            niceBtn.isSelected = model?.like == 1
            commonBtn.setTitle(" \(model!.com_num)", for: .normal)
            
            removeAllSubView()
            if let imgsArr = model?.show_img, imgsArr.count > 0 {
                var wid: CGFloat = autoSize(200)
                var count = 1
                if imgsArr.count == 2 {
                    count = 2
                    wid = autoSize(140)
                    imgContentHeight.constant = wid
                } else if imgsArr.count > 2 {
                    wid = (kScreenWidth - 30) / 3.0
                    count = imgsArr.count > 6 ? 6 : imgsArr.count
                    imgContentHeight.constant = count > 3 ? (wid * 2 + 5) : wid
                } else {
                    imgContentHeight.constant = wid
                }
                for i in 0 ..< count {
                    let imgView = UIImageView(frame: CGRect(x: (wid + 5) * CGFloat(i % 3) + 10, y: (wid + 5) * CGFloat(i / 3), width: wid, height: wid))
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
    
    
    @IBAction func niceClickAction(_ sender: UIButton) {
        if (self.niceBlock != nil) {
            self.niceBlock!()
        }
    }
    private func removeAllSubView() {
        let views = self.imgContentView.subviews
        for view in views {
            view.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
