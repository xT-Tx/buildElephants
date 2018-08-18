//
//  ViewController.swift
//  TwoDirectionScrollDemo
//
//  Created by JiangNan on 2018/8/12.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var collectionView: TwoDirectionCollectionView!
    
    let cvDelegate = CollectionViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = cvDelegate
        collectionView.dataSource = cvDelegate
        collectionView.layoutDelegate = cvDelegate
        
        collectionView.collectionViewContentChanged()
    }
}

