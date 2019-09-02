//
//  CustomRequestViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 9/1/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import Parse
import RxSwift
import RxCocoa

class CustomRequestViewModel {

    let requestSubmitted = BehaviorRelay<Bool>(value: false)

    func uploadCustomer(request: RequestOrderModel) {
        BriizeManager.shared.showLoader()

        let network = NetworkManager.instance
        network.postRequest(request, status: RequestState.ClientRequested.rawValue) { [weak self] (complete, requestId, error) in
            DispatchQueue.main.async {
                BriizeManager.shared.dismissloader()

                guard complete, error == nil
                    else {

                        return
                }

                self?.requestSubmitted.accept(true)
            }
        }
    }
}
