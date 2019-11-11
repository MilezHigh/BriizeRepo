//
//  BaseViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 5/21/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class BaseViewModel {

    let appState = BehaviorRelay<(BriizeApplicationState, String)>(value:(.loggedOut, "waiting"))

    private let disposeBag = DisposeBag()

    init() {
        print("Base View Active")

        BriizeManager
            .shared
            .persistedRequestState
            .asObservable()
            .bind(to: appState)
            .disposed(by: disposeBag)
    }
}
