//
//  AuctionDetailsViewController.swift
//  Briize
//
//  Created by Miles Fishman on 11/11/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class AuctionDetailsViewController: UIViewController {
    
    @IBOutlet weak var beforeImageView: UIImageView!
    @IBOutlet weak var afterImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    
    var model: RequestOrderModel? {
        didSet {
            guard let model = model else { return }
            beforeImageView.image = UIImage(data: model.beforeImage ?? Data())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
