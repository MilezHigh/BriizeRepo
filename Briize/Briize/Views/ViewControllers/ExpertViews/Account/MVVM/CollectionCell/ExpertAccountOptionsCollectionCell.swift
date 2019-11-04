//
//  ExpertAccountOptionsCollectionCell.swift
//  Briize
//
//  Created by Miles Fishman on 9/18/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class ExpertAccountOptionsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var optionTitle: UILabel!
    @IBOutlet weak var optionDescription: UILabel!
    
    var segueID:String = ""
    
    var model: ExpertAccountOption? {
        didSet {
            guard let m = model else {return}
            self.iconImageView.image = m.icon
            self.segueID = m.segueID
            self.optionTitle.text = m.name
            self.optionDescription.text = m.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.briizePink.cgColor
    }
}
