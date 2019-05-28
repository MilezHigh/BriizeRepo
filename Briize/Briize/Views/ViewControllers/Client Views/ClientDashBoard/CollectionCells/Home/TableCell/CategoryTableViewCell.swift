//
//  CategoryTableViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Hero

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var categoryTitleLabel: UILabel!

    var category: CategoryModel? {
        didSet{
            guard let model = category else {return}
            self.categoryImageView.image = model.image
            self.categoryTitleLabel.text = model.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        
        self.categoryImageView.darkOverlay()
        self.categoryImageView.hero.isEnabled = true
        self.categoryImageView.hero.id = "\(kHeroImage)"
    }
}
