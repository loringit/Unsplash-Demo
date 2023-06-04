//
//  PinterestLayout.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    
    func numberOfItems() -> Int
    func collectionView(_ collectionView: UICollectionView, ratioForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
    
}

class PinterestLayout: UICollectionViewLayout {
    
    // MARK: - Public properties
    
    weak var delegate: PinterestLayoutDelegate?
    
    // MARK: - Private properties
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // MARK: - Overrides
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        let numberOfItems = delegate?.numberOfItems() ?? 0
        
        guard
            cache.count != numberOfItems,
            let collectionView = collectionView
        else {
            return
        }
        
        if cache.count > numberOfItems {
            cache.removeAll()
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        if !cache.isEmpty {
            yOffset = [
                cache[cache.count - 2].frame.maxY,
                cache[cache.count - 1].frame.maxY
            ]
        }
        
        for item in cache.count ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoRatio = delegate?.collectionView(
                collectionView,
                ratioForPhotoAtIndexPath: indexPath
            ) ?? 180
            
            let height = cellPadding * 2 + columnWidth / photoRatio
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    // MARK: - Public methods
    
    func clearCache() {
        cache.removeAll()
    }
    
}
