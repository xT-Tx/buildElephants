//
//  TwoDirectionCollectionView.swift
//  TwoDirectionScrollDemo
//
//  Created by JiangNan on 2018/8/12.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class TwoDirectionCollectionView: UICollectionView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        collectionViewLayout = TwoDirectionCollectionViewLayout()
    }
    
    func collectionViewContentChanged() {
        if let layout = collectionViewLayout as? TwoDirectionCollectionViewLayout {
            layout.collectionViewContentChanged()
        }
    }
    
    weak var layoutDelegate: UICollectionViewDelegateFlowLayout?
}
