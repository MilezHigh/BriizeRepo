//
//  ExpertCompletedViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 10/15/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import Parse
import RxSwift
import RxCocoa

class ExpertCompletedViewModel {
    
    let requests = BehaviorRelay<[RequestOrderModel]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind()  {
        Observable<[RequestOrderModel]>
            .create ({ (observer) in
                let id = PFUser.current()?.objectId ?? ""
                let network = NetworkManager.instance
                
                network.pullRequests(for: id, isExpert: true) { (models) in
                    observer.onNext(models.compactMap({ $0 }))
                    observer.onCompleted()
                }
                
                return Disposables.create { }
            })
            .bind(to: requests)
            .disposed(by: disposeBag)
    }
}
