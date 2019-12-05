//
//  CustomOrdersViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 10/29/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class CustomOrdersViewModel {
    
    let userId: String
    let requests = BehaviorRelay<[RequestOrderModel]>(value: [])
    
    init(userId: String) {
        self.userId = userId
        
        fetchRequests()
    }
}

extension CustomOrdersViewModel {
    
    private func fetchRequests(for id: String) {
        let api = NetworkManager.instance
        api.pullRequests(type: "Custom") { [weak self] (models) in
            let results = models
                .compactMap({ $0 })
                .filter({
                    let req = $0
                    let location = CLLocation(
                        latitude : req.location?.latitude ?? 0,
                        longitude: req.location?.longitude ?? 0
                    )
                    let manager = BriizeManager.shared
                    return manager.userIsWithinFifteenMilesOf(location)
                })
                .compactMap({ $0 })
            
            self?.requests.accept(results)
        }
    }
    
    func fetchRequests() {
        fetchRequests(for: userId)
    }
}
