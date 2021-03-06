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
    
    let categories = BehaviorRelay<[CategoryModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    var id: String = "Account_Home"
    
    var model: ClientAccountCellModel? {
        didSet{
            guard let cell = model else {return}
            self.id = cell.id_name
            
            DispatchQueue.main.async {
                self.bindTable()
                
                let categories = CategoryModel.createFixedCategories()
                self.categories.accept(categories)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    private func bindTable() {
        categoryTableView.layer.cornerRadius = 20
        categoryTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryTableView.tableFooterView = UIView()
        categoryTableView.rowHeight = (categoryTableView.bounds.height / 4) - 16
        categories
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: categoryTableView.rx.items(
                cellIdentifier: "categoryCell",
                cellType      : CategoryTableViewCell.self
                )
            ) ({ _, category, cell in
                cell.category = category
            })
            .disposed(by: disposeBag)
        
        categoryTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension AccountHomeCollectionCell: UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        sessionManager.obtainAndSetRequest { (complete) in
            guard complete else { return }
            
            let cell = self.categoryTableView.cellForRow(at: indexPath) as! CategoryTableViewCell            
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

