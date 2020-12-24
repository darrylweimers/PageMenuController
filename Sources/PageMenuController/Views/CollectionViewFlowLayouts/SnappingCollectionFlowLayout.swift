//
//  SnappingCollectionFlowLayout.swift
//  PageSlider
//
//  Created by Darryl Weimers on 2020-09-26.
//

import UIKit

public class SnappingCollectionViewFlowLayout: UICollectionViewFlowLayout {

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)

        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        
//        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)) {
//            print("point: \(CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y))")
//            print("indexPath: \(indexPath.row)")
//        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
