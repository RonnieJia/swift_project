//
//  SearchCollectionViewCell.swift
//  SwiftApp
//
//  Created by jia on 2020/3/23.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    var imgView: UIImageView!
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height-40))
        self.contentView.addSubview(imgView)
        
        
        titleLabel = UILabel(frame: CGRect(x: 5, y: self.height-35, width: self.width-10, height: 30))
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
