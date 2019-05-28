//
//  ExpertEditServicesViewController.swift
//  Briize
//
//  Created by Miles Fishman on 9/24/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Hero

class ExpertEditServicesViewController: UIViewController {
    
    @IBOutlet weak var serviceCategoriesCollectionView: UICollectionView!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        
        self.bindServices()
        self.tableConfig()
    }
}

extension ExpertEditServicesViewController {
    
    fileprivate func bindServices() {
//        let services = CategoryModel.createAccountOptions()
//        
//        Observable.just(services)
//            .bind(
//                to: self.serviceCategoriesCollectionView.rx
//                    .items(
//                        cellIdentifier: "editableServiceCell",
//                        cellType: ServicesEditedCollectionViewCell.self)
//            ) { row, model, cell in
//                cell.model = model
//            }
//            .disposed(by: self.disposeBag)
//        
//        self.serviceCategoriesCollectionView.rx
//            .setDelegate(self)
//            .disposed(by: self.disposeBag)
    }
    
    fileprivate func tableConfig() {
        self.serviceCategoriesCollectionView.rx
            .itemSelected
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (index) in
                    guard let cell = self?.serviceCategoriesCollectionView.cellForItem(at: index) as? ServicesEditedCollectionViewCell,
                    let selectedImage = cell.serviceImageView.image
                        else {return}
                    
                    let vc = UIStoryboard(name: "ExpertFlow", bundle: nil).instantiateViewController(withIdentifier: "ServicesForCategoryViewController") as! ServicesForCategoryViewController
                    
                    kImageID = "\(arc4random_uniform(9999))"
                    kImageData = selectedImage.jpegData(compressionQuality: 1.0)
                    
                    let newID = kImageID
                    cell.serviceImageView.hero.id = newID
                    
                    vc.models = cell.serviceModels
                    
                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (_) in
                        DispatchQueue.main.async {
                             self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
                , onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
    }
}

extension ExpertEditServicesViewController: UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            let width = self.view.bounds.width - 32
            let height = self.view.bounds.height / CGFloat(collectionView.numberOfSections) / 2.5
            let size  = CGSize(width: width, height: height)
            return size
    }
    
}
