//
//  ExpertAccountViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 9/20/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Parse

class ExpertAccountViewModel {
    
    let accountOptions = BehaviorRelay<[ExpertAccountOption]>(value:[])
    
    init() {
        accountOptions.accept(layoutAccountOptions())
    }
}

extension ExpertAccountViewModel {
    
    func checkForExistingRequests() -> Observable<[RequestOrderModel]> {
        guard let id = PFUser.current()?.objectId else { return .just([]) }
        let network = NetworkManager.instance
        
        return Observable<[RequestOrderModel]>.create { (observer) in
            network.pullRequests(for: id, isExpert: true, isExactStatus: false) { (requests) in
                observer.onNext(
                    requests
                        .filter({ $0?.requestStatus != 5 })
                        .compactMap({ $0 })
                )
                observer.onCompleted()
            }
            
            return Disposables.create { }
        }
    }
    
    
    func layoutAccountOptions() -> [ExpertAccountOption] {
        let services = ExpertAccountOption(
            name: "Services",
            icon: UIImage(named: "services-xxl"), segueID: "showExpertServices", description:"Add, Remove, & Price the Services that you offer")
        
        let completedOrders = ExpertAccountOption(
            name: "Completed",
            icon: UIImage(named: "star-8-xxl"), segueID: "showExpertsCompletedOrders", description:"See the completed orders you have finished and have been paid for.")
        
        let payment = ExpertAccountOption(
            name: "Payment",
            icon: UIImage(named: "banknotes-xxl"), segueID: "showPayments", description:"View the history of all recieved payments.")
        
        let portfolio = ExpertAccountOption(
            name: "Portfolio",
            icon: UIImage(named: "portfolio"), segueID: "showPortfolio", description:"Link your Instagram or add photos that show off your work.")
        
        let support = ExpertAccountOption(
            name: "Support",
            icon: UIImage(named: "support-xxl"), segueID: "", description:"Send us an email describing your inquiry.")
        
        let logOut = ExpertAccountOption(
            name: "Log-Out",
            icon: UIImage(named: "account-logout-xxl"), segueID: "", description:"Log out of Briize. Your account will be offline once you log out.")
        
        let options: [ExpertAccountOption] = [services, payment, portfolio, support, completedOrders, logOut]
        return options
    }
}
