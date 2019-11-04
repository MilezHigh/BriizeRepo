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

class CustomOrdersViewModel {
    
    let userId: String
    let requests = BehaviorRelay<[RequestOrderModel]>(value: [])
    
    init(userId: String) {
        self.userId = userId
        self.fetchRequests(for: userId)
    }
}

extension CustomOrdersViewModel {
    
    private func fetchRequests(for id: String) {
        let api = NetworkManager.instance
        api.pullRequests(type: "Custom") { [weak self] (models) in
            self?.requests.accept(models.compactMap({ $0 }))
        }
    }
    
    func fetchRequests() {
        fetchRequests(for: userId)
    }
}
