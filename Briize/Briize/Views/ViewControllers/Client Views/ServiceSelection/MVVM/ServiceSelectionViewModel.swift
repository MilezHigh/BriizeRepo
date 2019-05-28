//
//  ServiceSelectionViewModel.swift
//  Briize
//
//  Created by Admin on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ServiceSelectionViewModel {
    
    private let disposeBag = DisposeBag()
    
    let services = BehaviorRelay<[ServiceModel]>(value:[])
    
    init(){
        BriizeManager.shared.user
            .selectedCategoryServices
            .bind(to: self.services)
            .disposed(by: self.disposeBag)
    }
}

extension ServiceSelectionViewModel {
    
    func subTypeAction(with subType: ServiceSubType) -> UIAlertAction {
        let action = UIAlertAction(
            title: subType.rawValue,
            style: .default
        ) { (_) in
            let copy = BriizeManager.shared.user
                .persistedServiceNames
                .filter({ $0 != subType.rawValue })
            
            BriizeManager.shared.user
                .persistedServiceNames = copy
            
            BriizeManager.shared.user
                .persistedServiceNames
                .append(subType.rawValue)
            
            print(BriizeManager.shared.user
                .persistedServiceNames)
        }
        return action
    }
    
    func process(name: String) -> [String]  {
        return []
    }
}
