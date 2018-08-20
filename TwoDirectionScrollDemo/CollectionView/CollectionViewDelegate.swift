//
//  CollectionViewDelegate.swift
//  TwoDirectionScrollDemo
//
//  Created by JiangNan on 2018/8/12.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit
class TextCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    
}

enum ScrollDirection {
    case none
    case vertical
    case horizontal
}

class CollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var previousContentOffset: CGPoint = CGPoint.zero
    private var direction: ScrollDirection = .none
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as? TextCell {
            cell.title.text = "section-\(indexPath.section) item-\(indexPath.item)"
        return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:150, height:50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath)
            return header
        }
        else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 0, height: 30)
        }
        else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == collectionView.numberOfSections - 1 {
            return CGSize(width: 0, height: 50)
        }
        else {
            return CGSize.zero
        }
    }

    //MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        previousContentOffset = scrollView.contentOffset
        
        direction = .none
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if direction == .none {
            let deltaX = fabs(previousContentOffset.x - scrollView.contentOffset.x)
            let deltaY = fabs(previousContentOffset.y - scrollView.contentOffset.y)
            if deltaX > deltaY {
                direction = .horizontal
            }
            else {
                direction = .vertical
            }
        }
        
        if direction == .horizontal {
            var offset = scrollView.contentOffset
            offset.y = previousContentOffset.y
            scrollView.contentOffset = offset
        }
        else if direction == .vertical {
            var offset = scrollView.contentOffset
            offset.x = previousContentOffset.x
            scrollView.contentOffset = offset
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        direction = .none
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        direction = .none
    }
}
