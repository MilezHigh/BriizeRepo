//
//  ExpertIGViewController.swift
//  Briize
//
//  Created by Admin on 6/20/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Hero

class ExpertIGViewController: UIViewController {
    @IBOutlet weak var expertImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        self.expertImageView.hero.id = "expertHeroImage"
        self.expertImageView.hero.modifiers = [.translate(y:100)]
        
    
    }
}
