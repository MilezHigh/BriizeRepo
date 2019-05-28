//
//  ServiceCollectionViewCell.swift
//  Briize
//
//  Created by Admin on 6/11/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import UIKit
import Hero

class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceLabelTitleLabel: UILabel!
    
    var service: ServiceModel? {
        didSet{
            guard let model = service else {return}
            self.serviceLabelTitleLabel.text = model.name
            super.awakeFromNib()
            self.serviceLabelTitleLabel.layer.cornerRadius = 12
            
            self.contentView.layer.cornerRadius = 2.0
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.borderColor = UIColor.clear.cgColor
            self.contentView.layer.masksToBounds = true
            
            self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            self.layer.shadowRadius = 12.0
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
        }
    }
}
