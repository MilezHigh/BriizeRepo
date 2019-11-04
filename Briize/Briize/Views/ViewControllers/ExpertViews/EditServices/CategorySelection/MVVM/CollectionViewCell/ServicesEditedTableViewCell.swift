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
            guard let model = model else { return }
            self.textLabel?.text = model.name
            self.detailTextLabel?.text = "$" + model.price.description
        }
    }
}
