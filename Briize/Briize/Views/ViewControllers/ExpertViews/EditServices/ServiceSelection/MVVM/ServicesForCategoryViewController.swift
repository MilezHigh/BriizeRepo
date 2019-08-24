//
//  ServicesForCategoryViewController.swift
//  Briize
//
//  Created by Miles Fishman on 9/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ServicesForCategoryViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesForCategory = BehaviorRelay<[ServiceModel]>(value:[])
    
    var gl: CAGradientLayer!
    
    var models: [ServiceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let colorTop = UIColor(red: 255.0/255.0, green: 175.0/255.0, blue: 189.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 160.0/255.0, alpha: 1.0).cgColor
        
        gl = CAGradientLayer()
        gl.frame = self.view.bounds
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        self.serviceTableView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        self.view.layer.insertSublayer(gl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.bind()
    }
    
    fileprivate func setup(){
        guard let data = kImageData else {return}
        self.categoryImageView.image = UIImage(data: data)
    }
    
    fileprivate func bind() {
        self.servicesForCategory.accept(self.models)
        self.servicesForCategory
            .bind(to: self.serviceTableView.rx
                .items(cellIdentifier: "expertCElll",
                       cellType: UITableViewCell.self)
        ) { _, model, cell in
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .white
            cell.textLabel?.text = model.name
            cell.backgroundColor = .clear
            
        }
        .disposed(by: self.disposeBag)
    }
    
    
}
