//
//  CategoryTableViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!

    var category: CategoryModel? {
        didSet{
            guard let model = category else {return}
            categoryImageView.image = model.image
            categoryTitleLabel.text = model.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        categoryImageView.darkOverlay()
    }
}
