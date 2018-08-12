//
//  TwoDirectionCollectionView.swift
//  TwoDirectionScrollDemo
//
//  Created by JiangNan on 2018/8/12.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class TwoDirectionCollectionView: UICollectionView {

    required init() {
        super.init(frame: CGRect.zero, collectionViewLayout: TwoDirectionCollectionViewLayout())
        
        let dataSourceDelegate = CollectionViewDelegate()
        self.dataSource = dataSourceDelegate
        self.delegate = dataSourceDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
