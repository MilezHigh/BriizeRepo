//
//  LoginViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 6/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Parse

class LoginViewModel {
    
    let userSegueIdSignal = BehaviorRelay<String>(value:"waiting")
    
    func logIn(username: String, password: String) {
        let network = NetworkManager.instance
        network.login(username: username, password: password) { (model) in
            BriizeManager.shared.dismissloader()
            
            if let user = model {
                DispatchQueue.main.async { [weak self] in
                    BriizeManager.shared.user.model.accept(user)
                    
                    self?.userSegueIdSignal
                        .accept(user.isExpert ? "showExpertMainDashboard" : "showClientMainDashboard")
                }
            } else {
                print("Error occured when fetching user")
            }
        }
    }
}
