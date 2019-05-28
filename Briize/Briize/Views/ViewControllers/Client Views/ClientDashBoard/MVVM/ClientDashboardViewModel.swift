//
//  CategoryViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ClientDashboardViewModel {
    
    let segueSignal = BehaviorRelay<String>(value:"waiting")
    let options = BehaviorRelay<[AccountSectionModel]>(value: [])
    let user = BehaviorRelay<UserModel?>(value: nil)
    
    fileprivate let disposebag = DisposeBag()
    
    init() {
        BriizeManager
            .shared
            .user
            .model
            .asObservable()
            .bind(to: self.user)
            .disposed(by: self.disposebag)
        
        BriizeManager
            .shared
            .persistedSegueId
            .asObservable()
            .bind(to: self.segueSignal)
            .disposed(by: self.disposebag)
        
        let options = CategoryModel.createAccountOptions()
        self.options.accept(options)
    }
}

extension CategoryModel {
    
    static func createAccountOptions() -> [AccountSectionModel] {
        let home = ClientAccountCellModel.init(.Home)
        let prior = ClientAccountCellModel.init(.Prior)
        
        let homeItem = AccountSectionItem.home(model: home)
        let priorItem = AccountSectionItem.prior(model: prior)
        let sectionModel = AccountSectionModel.accountOptions(title: "", items: [homeItem, priorItem])
        
        return  [sectionModel]
    }
    
}

extension CategoryModel {
    
    func bindUser()  {
       
    }
}
