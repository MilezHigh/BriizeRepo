//
//  ClientDashBoardView.swift
//  Briize
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class ClientDashBoardView: UIView {
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientImageView: UIImageView!
    @IBOutlet weak var clientPriorOrders: UILabel!
    @IBOutlet weak var clientSchedRequestsLabel: UILabel!
    
    @IBOutlet weak var findExpertsButtonOutlet: UIButton!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    @IBOutlet weak var changeLocationButtonOutlet: UIButton!
    
    class func create() -> ClientDashBoardView {
        let view: ClientDashBoardView = UIView.fromNib()
        view.findExpertsButtonOutlet.layer.cornerRadius = 25
        view.changeLocationButtonOutlet.layer.cornerRadius = 25
        view.menuButtonOutlet.layer.cornerRadius = 20
        view.clientImageView.layer.cornerRadius = 45
        view.clientImageView.layer.borderWidth = 1.0
        view.clientImageView.layer.borderColor = UIColor.black.cgColor
        return view
    }
    
    @IBAction func findExpertsButtonPressed(_ sender: Any) {
         BriizeManager.shared.user.openCategorySelection.accept(true)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {

    }
    
    @IBAction func chnageLocationButtonPressed(_ sender: Any) {
        
    }
}
