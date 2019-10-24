//
//  ServicesEditedCollectionViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 9/25/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import UIKit

public var kImageData: Data? = nil

class ServicesEditedTableViewCell: UITableViewCell {
    
    var serviceModels: [ServiceModel] = []
    
    var model: ServiceObject? {
        didSet{
            textLabel?.text = model?.name
            detailTextLabel?.text = "$\(model?.price ?? 0)"
        }
    }
}
