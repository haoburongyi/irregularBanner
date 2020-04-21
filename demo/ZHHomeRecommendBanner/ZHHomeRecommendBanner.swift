//
//  ZHCardSwitch.swift
//  CardDemo
//
//  Created by zhanghao on 2019/8/21.
//  Copyright © 2019 zhanghao. All rights reserved.
//

import UIKit

@objc protocol ZHHomeRecommendBannerDelegate: NSObjectProtocol {
    
    /// 点击卡片代理方法
    @objc optional func didSelectedItem(index: Int)
    
    /// 滚动卡片代理方法
    @objc optional func didChangePage(index: Int)
}

class ZHHomeRecommendBanner: UIView {
    
    public var models: [String] = [] {
        didSet {
//            if let model = models.first {
//                guard let width = model.cover?.width?.doubleValue,
//                    let height = model.cover?.height?.doubleValue else { return }
//                layout.setWidthHeightScale(CGFloat(width / height))
//            }
            guard models.count > 1 else {
                selectedIndex = 0
                coefficient = 1
                collectionView.isScrollEnabled = false
                collectionView.reloadData()
                return
            }
            coefficient = 1000
            collectionView.isScrollEnabled = true
            collectionView.reloadData()
            DispatchQueue.main.async {
                self.selectedIndex = self.models.count * self.coefficient / 2
                self.scrollToCenterAnimated(false)
                self.startAutoNextPage()
            }
        }
    }
    private var collectionView: UICollectionView!
    private let layout = ZHHomeRecommendBannerFlowLayout()
    private var coefficient = 1000
    private var dragAtIndex: Int = 0
    private var dragStartX: CGFloat = 0
    private var dragEndX: CGFloat = 0
    private var isDraging = false {
        didSet {
            cancelAutoNextPage()
            if isDraging == false {   
                startAutoNextPage()
            }
        }
    }
    
    public var delegate: ZHHomeRecommendBannerDelegate?
    public var pagingEnabled = true
    public var autoTimInterval: TimeInterval = 0// 非 0 自动滚动
    public var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

// MARK: - Public
extension ZHHomeRecommendBanner {
    
    public func switchToIndex(index: Int, animated: Bool) {
        
        selectedIndex = index
        scrollToCenterAnimated(animated)
    }
    
    public func setSelectedIndex(index: Int) {
        selectedIndex = index
        switchToIndex(index: index, animated: false)
    }
}

// MARK: - Actions
extension ZHHomeRecommendBanner {
    
    @objc
    private func autoNextPage() {
        
        guard isDraging == false else {
            return
        }
        selectedIndex += 1
        guard selectedIndex < collectionView.numberOfItems(inSection: 0) else {
            return
        }
        collectionView.scrollToItem(at: .init(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension ZHHomeRecommendBanner: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        guard pagingEnabled else { return }
        dragStartX = scrollView.contentOffset.x
        dragAtIndex = selectedIndex
        isDraging = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        guard pagingEnabled else { return }
        dragEndX = scrollView.contentOffset.x
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard autoTimInterval != 0 else {
            return
        }
        isDraging = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if isDraging {
            isDraging = false
        }
        
        if selectedIndex >= models.count * coefficient * 10 / 8 || selectedIndex <= models.count * coefficient * 10 / 2 {
            selectedIndex = selectedIndex % models.count + models.count * 5
            self.collectionView.scrollToItem(at: .init(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        cancelAutoNextPage()
        startAutoNextPage()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        scrollToCenterAnimated(true)
        guard models.count > 0 else { return }
        delegate?.didSelectedItem?(index: selectedIndex % models.count)
    }
    
}

// MARK: - UICollectionViewDataSource
extension ZHHomeRecommendBanner: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return models.count * coefficient
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeRecommendBannerCell", for: indexPath) as! HomeRecommendBannerCell
        let imageName = models[indexPath.row % models.count]
        cell.imageView.image = UIImage.init(named: imageName)
//        cell.imageView.yw_setImageWithUrlStr(with: model.cover.url)
//        cell.contentView.backgroundColor = .red
//        cell.backgroundColor = .red
        return cell
    }
}

// MARK: - Private
extension ZHHomeRecommendBanner {
    
    private func startAutoNextPage() {
        guard autoTimInterval != 0 else {
            return
        }
        perform(#selector(autoNextPage), with: nil, afterDelay: autoTimInterval)
    }
    
    private func cancelAutoNextPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoNextPage), object: nil)
    }
    
    private func updateSelectedIndex(indexPath: IndexPath) {
        
        guard indexPath.row != selectedIndex else { return }
        
        selectedIndex = indexPath.row
        guard models.count > 0 else { return }
        delegate?.didChangePage?(index: selectedIndex % models.count)
    }
    
    private func fixCellToCenter() {
        
        guard selectedIndex == dragAtIndex else {
            scrollToCenterAnimated(true)
            return
        }
        
        // 滚动最小距离
        let dragMiniDistance = bounds.width / 20
        if dragStartX - dragEndX >= dragMiniDistance {
            selectedIndex -= 1 // 向左
        } else if dragEndX - dragStartX >= dragMiniDistance {
            selectedIndex += 1 //向右
        }
        let maxIndex = collectionView.numberOfItems(inSection: 0) - 1
        selectedIndex = selectedIndex <= 0 ? 0 : selectedIndex
        selectedIndex = selectedIndex >= maxIndex ? maxIndex : selectedIndex
        scrollToCenterAnimated(true)
    }
    
    /// 滚动到中间
    private func scrollToCenterAnimated(_ animated: Bool) {
        guard models.count > 0 else { return }
        collectionView.scrollToItem(at: .init(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
}

// MARK: - UI
extension ZHHomeRecommendBanner {
    
    private func addCollectionView() {
        
        layout.centerBlock = {[weak self] indexPath in
            guard let self = self else { return }
            self.updateSelectedIndex(indexPath: indexPath)
        }
        collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = true
        
        collectionView.register(HomeRecommendBannerCell.self, forCellWithReuseIdentifier: "HomeRecommendBannerCell")
        addSubview(collectionView)
        
        DispatchQueue.main.async {
            self.selectedIndex = self.models.count * self.coefficient / 2
            self.scrollToCenterAnimated(false)
        }
    }
}
