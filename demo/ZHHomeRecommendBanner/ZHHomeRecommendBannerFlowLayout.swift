//
//  ZHCardSwitchFlowLayout.swift
//  CardDemo
//
//  Created by zhanghao on 2019/8/21.
//  Copyright © 2019 zhanghao. All rights reserved.
//

import UIKit

class ZHHomeRecommendBannerFlowLayout: UICollectionViewFlowLayout {

    var centerBlock: ((IndexPath) -> ())?
    
    private var cardWidthScale: CGFloat = 0.7
    private let cardHeightScale: CGFloat = 1.0
    public var shouldInvalidateLayout = true
    private var alreadySetScaleWidth = false
    private let leftMargin: CGFloat = UIScreen.main.bounds.width * 0.3 * 0.5
    
    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        sectionInset = .init(top: insetY(), left: insetX(), bottom: insetY(), right: insetX())
        itemSize = .init(width: itemWidth(), height: itemHeight())
//        minimumLineSpacing = -itemWidth() * 0.06
        minimumLineSpacing = 10
    }
    
    public func setWidthHeightScale(_ scale: CGFloat) {
        alreadySetScaleWidth = true
        cardWidthScale = scale
        prepare()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return shouldInvalidateLayout
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let collectionView = collectionView else {
            return nil
        }
        
        guard let attributesArr = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width * 0.5

        let maxApart = (collectionView.bounds.width + itemWidth()) * 0.5
//        let maxApart = (collectionView.bounds.width + itemWidth()) * 0.6
        
        var index = 0
        for attributes in attributesArr {

            // 获取cell中心和屏幕中心的距离
            let apart = abs(attributes.center.x - centerX)
//            // 移动进度 -1~0~1
            let progress = apart / maxApart
            // 在屏幕外的cell不处理
            if abs(progress) > 1 {
                continue
            }
            
            var _progress = (attributes.center.x - centerX) / maxApart
            if _progress < 0 {
                _progress += 1
            }
            // 缩放大小
            let x = (attributes.size.width + minimumLineSpacing) * CGFloat(attributes.indexPath.row) + insetX()
            if index == 0 {
                attributes.frame.origin.x = x - leftMargin * progress
            } else {
                attributes.frame.origin.x = x
                if index != 1 {
                    // 根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
                    var scale = abs(cos(progress * CGFloat.pi / 4))
                    if scale != 1 {
                        scale *= 1.2
                        if scale > 1 {
                            scale = 1
                        }
                    }
                    // 缩放大小
                    attributes.transform = .init(scaleX: scale, y: scale)
                }
            }
            index += 1
            
            // 更新中间位
            if apart < itemWidth() * 0.5 {
                centerBlock?(attributes.indexPath)
            }
        }
        return attributesArr
    }
}


extension ZHHomeRecommendBannerFlowLayout {
    
    private func itemWidth() -> CGFloat {
        
        return (collectionView?.bounds.width ?? 0) * cardWidthScale
    }
    
    private func itemHeight() -> CGFloat {
        if alreadySetScaleWidth {
            return itemWidth() / cardWidthScale
        }
        return (collectionView?.bounds.height ?? 0) * cardHeightScale
    }
    
    private func insetX() -> CGFloat {
        
        guard let collectionView = collectionView else {
            return 0
        }
        return (collectionView.bounds.width - itemWidth()) / 2
    }
    
    private func insetY() -> CGFloat {
        
        guard let collectionView = collectionView else {
            return 0
        }
        return (collectionView.bounds.height - itemHeight()) / 2
    }
}
