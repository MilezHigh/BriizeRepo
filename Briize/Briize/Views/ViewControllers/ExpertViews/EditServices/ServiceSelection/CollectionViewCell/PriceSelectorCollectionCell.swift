//
//  ServiceForCategoryCollectionCell.swift
//  Briize
//
//  Created by Miles Fishman on 9/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class PriceSelectorCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 6
    }
    
}
