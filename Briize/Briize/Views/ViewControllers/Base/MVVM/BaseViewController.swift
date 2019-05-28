//
//  BaseViewController.swift
//  Briize
//
//  Created by Admin on 5/21/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    var myTimer:Timer?
    
    private let viewModel = BaseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadClientDemo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       self.myTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (_) in
        guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                 strongSelf.performSegue(withIdentifier: "showLogin", sender: strongSelf)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.myTimer?.invalidate()
        self.myTimer = nil
    }
    
}

extension BaseViewController {
    
    // Demo
    
    private func loadClientDemo() {
        
        
        
    }
    
    // private func loadExpertdemo(){}
    
}
