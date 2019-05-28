//
//  MyAccountCollectionViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 8/13/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class MyAccountCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var accountOptionLabel: UILabel!
    
    var model: [String:String]? {
        didSet{
            guard let dic = model else {return}
            self.accountOptionLabel.text = dic.keys.first
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accountOptionLabel.layer.borderColor = UIColor.black.cgColor
        self.accountOptionLabel.layer.borderWidth = 1.0
        self.accountOptionLabel.layer.cornerRadius = 8
    }
}
