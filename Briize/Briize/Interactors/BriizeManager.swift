//
//  Constants.swift
//  Briize
//
//  Created by Miles Fishman on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa

public enum UserType {
    case Client
    case Expert
}

public enum RequestOrderType {
    case Live
    case Custom
}

public enum RequestState: Int {
    case Idle = 0
    case ClientRequested = 1
    case ExpertAccepted = 2
    case Active = 3
    case Complete = 4
    case Cancelled = 5
    case ExpertReceivedRequest = 6
    case ConfirmClientPayment = 7
    
    var userFriendlyMessage: String {
        switch self {
        case .Idle:
            return "Idle"
        case .ClientRequested:
            return "Beauty Request Placed"
        case .ExpertAccepted:
            return  "Request Accepted."
        default:
            return ""
        }
    }
    
    static func create(from id: Int) -> RequestState {
        switch id {
        case 1:
            return .ClientRequested
        case 2:
            return .ExpertAccepted
        case 3:
            return .Active
        case 4:
            return .Complete
        case 5:
            return .Cancelled
        case 6:
            return .ExpertReceivedRequest
        case 7:
            return .ConfirmClientPayment
        default:
            return .Idle
        }
    }
}

class BriizeManager {
    let api = NetworkManager.instance
    let user = User()
    
    var userType: UserType = .Client
    var liveController = BehaviorRelay<UIViewController?>(value: nil)
    var requestType = BehaviorRelay<RequestOrderType>(value: .Live)
    var requestState = BehaviorRelay<RequestState>(value: .Idle)
    var persistedSegueId = BehaviorRelay<String>(value: "waiting")
    var persistedAppState = BehaviorRelay<(BriizeApplicationState, String)>(value: (.loggedOut, "waiting"))
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    static let shared: BriizeManager = BriizeManager() 
    
    private init() {
        requestState
            .asObservable()
            .subscribe(
                onNext: { [weak self] (state) in
                    self?.process(state)
            })
            .disposed(by: self.disposeBag)
    }
}

extension BriizeManager {
    
    private func process(_ state: RequestState) {
        switch state {
        case .Idle:
            break
            
        case .ClientRequested:
            break
            /// send request or re-ignite timer
            /// show request view with state
            
        case .ExpertAccepted:
            break
            /// send request or re-ignite timer
            /// show request view with state
            
        case .Active:
            break
            /// show request view with state
            
        case .Complete:
            break
            
        case .Cancelled:
            break
            
        case .ExpertReceivedRequest:
            break
            
        case .ConfirmClientPayment:
            break
            
        }
    }
}

extension BriizeManager {
    
    public func adoptController(_ controller: UIViewController?) {
        self.liveController.accept(controller)
    }
    
    public func setLoaderMessage(message: String) {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    public func dismissloader() {
        if NVActivityIndicatorPresenter.sharedInstance.isAnimating {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
    
    public func showLoader(_ message: String = "") {
        let color = UIColor(red: 214/255, green: 165/255, blue: 141/255, alpha: 1.0)
        let data = ActivityData(
            size: CGSize(width: 80, height: 80),
            message: message,
            messageFont: UIFont.init(name: "Lobster", size: 22.0),
            messageSpacing: 4.0,
            type: NVActivityIndicatorType.ballGridPulse,
            color: color,
            padding: 0,
            displayTimeThreshold: nil,
            minimumDisplayTime: nil,
            backgroundColor: nil,
            textColor: .white
        )
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
    }
    
    // Client Methods

    /// - Note:
    /// - Method below presents an action sheet, a constraint error shows up in the console,
    /// - However this is a bug on Apple's part. Does not break anything otherwise. Issue noted below.
    /// - https://github.com/lionheart/openradar-mirror/issues/21120

    public func obtainAndSetRequest(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title         : nil,
            message       : nil,
            preferredStyle: .actionSheet
        )
        let action = UIAlertAction(title: "Live Request", style: .default)
        { [weak self] (_) in
            self?.requestType.accept(.Live)
            kHeroImage = Int(arc4random_uniform(1000))
            DispatchQueue.main.async {
                completion(true)
            }
        }
        let actionTwo = UIAlertAction(title: "Custom Request", style: .default)
        { [weak self] (_) in
            self?.requestType.accept(.Custom)
            kHeroImage = Int(arc4random_uniform(1000))
            DispatchQueue.main.async {
                completion(true)
            }
        }
        let actionThree = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            DispatchQueue.main.async {
                completion(false)
            }
        }
        alert.addAction(action)
        alert.addAction(actionTwo)
        alert.addAction(actionThree)
        
        DispatchQueue.main.async {
            self.liveController.value?.present(alert, animated: true, completion: nil)
        }
    }

    public func changeAddressForCurrentUser(formatted: String, state: String, zipcode: String) {
        let api = NetworkManager.instance
        let result = api.updateUserAddress(formatted: formatted, state: state, zipcode: zipcode)
        result
            .asDriver(onErrorJustReturn: (false, nil))
            .drive(onNext: { [weak self] (arg) in
                let alert = UIAlertController(title: "Address Updated!", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self?.liveController.value?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
