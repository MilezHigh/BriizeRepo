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
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var beforeImageView: UIImageView!
    @IBOutlet weak var afterImageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    
    var model: RequestOrderModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addDismissButton()
    }
    
    private func setup() {
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v
        
        guard let model = model else { return }
        notesLabel.text = model.notes
        priceLabel.text = "$" + model.cost.description
        beforeImageView.image = UIImage(data: try! model.beforeImage?.getData() ?? Data())
        afterImageView.image = UIImage(data: try! model.afterImage?.getData() ?? Data())
    }
    
    deinit {
        print("deinit - \(self.description)")
    }
}
