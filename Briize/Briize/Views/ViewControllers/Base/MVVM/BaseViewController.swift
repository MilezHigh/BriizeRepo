//
//  BaseViewController.swift
//  Briize
//
//  Created by Miles Fishman on 5/21/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum BriizeApplicationState {
    case loggedOut
    case authenticated
}

class BaseViewController: UIViewController {

    private let viewModel = BaseViewModel()
    private let disposeBag = DisposeBag()

    private var isInstantiated: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isInstantiated else { return }
        isInstantiated = true

        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

extension BaseViewController {

    private func bind() {
        viewModel
            .appState
            .throttle(0.3, latest: true, scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: (.loggedOut, "waiting"))
            .drive(
                onNext: { [weak self] in
                    guard self?.isViewLoaded == true else { return }
                    let segueId = $0.0 == .loggedOut ? "showLogin" : $0.1
                    self?.performSegue(withIdentifier: segueId, sender: self)
            })
            .disposed(by: disposeBag)
    }
}
