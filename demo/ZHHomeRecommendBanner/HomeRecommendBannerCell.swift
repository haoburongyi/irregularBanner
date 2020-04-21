//
//  ZHCardSwitchCell.swift
//  CardDemo
//
//  Created by zhanghao on 2019/8/21.
//  Copyright © 2019 zhanghao. All rights reserved.
//

import UIKit
//import SnapKit

class HomeRecommendBannerCell: UICollectionViewCell {
    
    let imageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
//        imageView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
