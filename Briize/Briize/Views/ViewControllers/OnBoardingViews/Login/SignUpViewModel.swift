//
//  SignUpViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 8/28/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import Parse
import RxSwift
import RxCocoa

struct UserPartialModel {
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var password: String
    var certImageData: Data? = nil
    var servicesAppliedFor: [String] = []
}

class SignUpViewModel {

    var selected: ((_ services: [Int]) -> ())?

    let signUpSuccess = BehaviorRelay<(Bool, UserPartialModel?, Error?)>(value: (false, nil, nil))

    private let disposebag = DisposeBag()

    init() { }

    func signUpUser(
        model             : UserPartialModel,
        certImageData     : Data? = nil,
        servicesAppliedFor: [String] = []
        ) {
        let network = NetworkManager.instance
        network
            .signUpUser(
                model             : model,
                certImageData     : certImageData,
                servicesAppliedFor: servicesAppliedFor
            )
            .asObservable()
            .do(onNext: {
                guard $0.0, let model = $0.1 else { return }
                UserDefaults.standard.set(model.email, forKey: "Username")
                UserDefaults.standard.set(model.password, forKey: "Password")
            })
            .bind(to: signUpSuccess)
            .disposed(by: disposebag)
    }
}
