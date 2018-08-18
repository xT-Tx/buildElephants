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

class CollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    

}
