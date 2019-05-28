//
//  AccountHomeCollectionCell.swift
//  Briize
//
//  Created by Miles Fishman on 11/8/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class AccountHomeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var id: String = "Account_Home"
    
    let categories = BehaviorRelay<[CategoryModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    var model: ClientAccountCellModel? {
        didSet{
            guard let cell = model else {return}
            self.id = cell.id_name
            
            let categories = AccountHomeCollectionCell.createFixedCategories()
            self.categories.accept(categories)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        
        self.categoryTableView.layer.cornerRadius = 15
        self.categoryTableView.tableFooterView = UIView()
        self.categoryTableView.rowHeight = (self.categoryTableView.frame.size.height/4) - 16
        
        self.categories
            .asDriver()
            .drive(
                self.categoryTableView.rx
                    .items(
                        cellIdentifier : "categoryCell",
                        cellType       : CategoryTableViewCell.self
                )
            ) { row, category, cell in
                cell.category = category
            }
            .disposed(by: self.disposeBag)
        
        self.categoryTableView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
}

extension AccountHomeCollectionCell: UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        BriizeManager.shared.obtainAndSetRequest { (complete) in
            guard complete else { return }
            
            let cell = self.categoryTableView.cellForRow(at: indexPath) as! CategoryTableViewCell
            cell.hero.id = "\(kHeroImage)"
            
            let img = cell.categoryImageView.image ?? #imageLiteral(resourceName: "Briizelogo")
            let title = cell.categoryTitleLabel.text!
            let chosenCategory = CategoryModel(name: title, image: img)
            let services = ServiceModel.addServicesToCategory(chosenCategory)
            
            BriizeManager.shared.user.selectedCategoryImage.accept(img)
            BriizeManager.shared.user.selectedCategoryName.accept(title)
            BriizeManager.shared.user.selectedCategoryServices.accept(services)
            BriizeManager.shared.persistedSegueId.accept("selectServiceSegue")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245.0
    }
}

extension AccountHomeCollectionCell {
    
    static func createFixedCategories() -> [CategoryModel] {
        let hair = CategoryModel(name: "Hair", image: #imageLiteral(resourceName: "hairImg"))
        let makeUp = CategoryModel(name: "Make-Up", image: #imageLiteral(resourceName: "makeUpImg"))
        let eyesbrows = CategoryModel(name: "Eyes & Brows", image: #imageLiteral(resourceName: "eyesBrowsImg"))
        let nails = CategoryModel(name: "Nails", image: #imageLiteral(resourceName: "nailsImg"))
        let mens = CategoryModel(name: "Men's", image: #imageLiteral(resourceName: "menImg"))
        let categories = [
            hair, makeUp, eyesbrows, nails, mens
        ]
        return  categories
    }
}
