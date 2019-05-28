//
//  ServicesEditedCollectionViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 9/25/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import UIKit
import Hero

public var kImageID: String = ""
public var kImageData: Data? = nil

class ServicesEditedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceImageView: UIImageView!
    
    @IBOutlet weak var serviceTitleLabel: UILabel!
    
    var serviceModels:[ServiceModel] = []
    
    var model: CategoryModel? {
        didSet{
            guard let category = model else {return}
            let fixedCategories = ServiceModel.addServicesToCategory(category)
            self.serviceModels = fixedCategories
            self.serviceImageView.image = category.image
            self.serviceTitleLabel.text = category.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.serviceImageView.hero.isEnabled = true
        
        self.layer.cornerRadius = 6
    }
}
