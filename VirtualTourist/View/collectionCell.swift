//
//  collectionCell.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/24/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import UIKit



class collectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.lightGray : UIColor.clear
        }
    }
}
