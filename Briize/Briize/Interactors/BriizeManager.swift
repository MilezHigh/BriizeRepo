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
import CoreLocation

public enum UserType {
    case Client
    case Expert
}

public enum RequestOrderType {
    case Live
    case Custom
}

enum RequestStatus: Int {
    case Idle = 0
    case NewClientRequest = 1
    case RequestPending = 2
    case InRoute = 3
    case Active = 4
    case Complete = 5
    case Cancelled = 6
    
    /// - Note: ( ** 7, 8, 9 - Not Used ** )
    case ExpertReceivedRequest = 7
    case ConfirmClientPayment = 8
    case ExpertAccepted = 9
    ///
    
    var userFriendlyMessage: String {
        switch self {
        case .Idle            : return "Idle"
        case .NewClientRequest: return "Beauty Request Placed"
        case .ExpertAccepted  : return "Request Accepted."
        default               : return ""
        }
    }
    
    static func create(from id: Int) -> RequestStatus {
        switch id {
        case 1 : return .NewClientRequest
        case 2 : return .RequestPending
        case 3 : return .ExpertAccepted
        case 4 : return .Active
        case 5 : return .Complete
        case 6 : return .Cancelled
            
        /// - Note: 7, 8, 9 - Not used
        case 7 : return .ExpertReceivedRequest
        case 8 : return .ConfirmClientPayment
        case 9 : return .InRoute
            ///
            
        default: return .Idle
        }
    }
}

class BriizeManager {
    
    var liveController = BehaviorRelay<UIViewController?>(value: nil)
    
    var requestType = BehaviorRelay<RequestOrderType>(value: .Live)
    var requestState = BehaviorRelay<RequestStatus>(value: .Idle)
    
    var persistedSegueId = BehaviorRelay<String>(value: "waiting")
    var persistedRequestState = BehaviorRelay<(BriizeApplicationState, String)>(value: (.loggedOut, "waiting"))
    
    let api = NetworkManager.instance
    let user = User()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    static let shared: BriizeManager = BriizeManager()
    
    static var userType: UserType {
        get {
            BriizeManager.shared.user.model.value?.isExpert == true ? .Expert : .Client
        }
    }
    
    private init() {
        requestState
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.process($0) })
            .disposed(by: disposeBag)
        
        user
            .model
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                guard let user = $0 else { return }
                self?.saveUser(model: user)
            })
            .disposed(by: disposeBag)
    }
}

extension BriizeManager {
    
    private func process(_ state: RequestStatus) {
        switch state {
        case .Idle:
            break
            
        case .NewClientRequest:
            break
            /// send request or re-ignite timer
            /// show request view with state
            
        case .ExpertAccepted:
            break
            /// send request or re-ignite timer
            /// show request view with state
            
        case .RequestPending:
            break
            
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
            
        case .InRoute:
            break
        }
    }
    
    private func saveUser(model: UserModel?) {
        guard let user = model else { return }
        let api = NetworkManager.instance
        api
            .updateCurrentLocation(for: user)
            .asObservable()
            .subscribe(
                onNext: { (arg) in
                    guard arg.0 else { return}
                    print("SUCCESS ON SAVING USER")
            },
                onError: { (error) in
                    print("ERROR ON SAVING USER - " + error.localizedDescription)
            })
            .disposed(by: disposeBag)
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
        let color: UIColor = .briizePink
        let data = ActivityData(
            size: CGSize(width: 80, height: 80),
            message: message,
            messageFont: UIFont.init(name: "Lobster", size: 22.0),
            messageSpacing: 4.0,
            type: NVActivityIndicatorType.ballSpinFadeLoader,
            color: color,
            padding: 0,
            displayTimeThreshold: nil,
            minimumDisplayTime: nil,
            backgroundColor: nil,
            textColor: .white
        )
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, nil)
    }
    
    // MARK: - Client Methods
    
    public func changeAddressForCurrentUser(formatted: String, state: String, zipcode: String) {
        let api = NetworkManager.instance
        let result = api.updateUserAddress(formatted: formatted, state: state, zipcode: zipcode)
        result
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (arg) in
                guard arg.0 else { return }
                let alert = UIAlertController(title: "Address Updated!", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self?.liveController.value?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
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
        let action = UIAlertAction(title: "Live Request",
                                   style: .default)
        { [weak self] (_) in
            self?.requestType.accept(.Live)
            DispatchQueue.main.async {
                completion(true)
            }
        }
        let actionTwo = UIAlertAction(title: "Custom Request",
                                      style: .default)
        { [weak self] (_) in
            self?.requestType.accept(.Custom)
            DispatchQueue.main.async {
                completion(true)
            }
        }
        let actionThree = UIAlertAction(title: "Cancel",
                                        style: .cancel)
        { _ in
            DispatchQueue.main.async {
                completion(false)
            }
        }
        alert.addAction(action)
        alert.addAction(actionTwo)
        alert.addAction(actionThree)
        
        DispatchQueue.main.async { [weak self] in
            self?.liveController.value?.present(alert, animated: true)
        }
    }
}

extension BriizeManager {
    
        public var currentUserLocation: CLLocation {
            let lat = user.model.value?.currentLocation?.latitude ?? 0
            let lon = user.model.value?.currentLocation?.longitude ?? 0
            return CLLocation(latitude: lat, longitude: lon)
        }
        
        public func userIsWithinFifteenMilesOf(_ requestLocation: CLLocation) -> Bool {
            let distance = currentUserLocation.distance(from: requestLocation)
            return distance.magnitude <= Double.fifteenMilesInMeters
        }
}
