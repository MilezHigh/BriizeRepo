//
//  RequestOrderViewModel.swift
//  Briize
//
//  Created by Miles Fishman on 4/30/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Parse

class RequestOrderViewModel {
    
    let shouldDismiss = BehaviorRelay<Bool>(value: false)
    let expertDidApprove = BehaviorRelay<Bool>(value: false)
    let needForExpertApproval = BehaviorRelay<Bool>(value: false)
    let requestOrder = BehaviorRelay<RequestOrderModel?>(value: nil)
    let requestState = BehaviorRelay<RequestState>(value: .NewClientRequest)
    
    private var requestedPosted: Bool = false
    private var timerDidLap: Bool = false
    
    private let disposeBag = DisposeBag()
    
    init(_ requestOrder: RequestOrderModel, state: RequestState) {
        self.requestOrder.accept(requestOrder)
        self.requestState.accept(state)
        self.observeState()
    }
}

extension RequestOrderViewModel {
    
    func observeState() {
        requestState
            .asObservable()
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .NewClientRequest:
                    self?.observeClientRequest()
                    
                case .RequestPending:
                    var model = self?.requestOrder.value
                    model?.requestStatus = state.rawValue
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(150)) {
                        self?.checkRequestStatus(model?.id, restartTimer: false)
                    }
                    
                case .ExpertReceivedRequest:
                    self?.obtainExpertApproval()
                    
                case .ExpertAccepted:
                    break // MILES YOUR HERE
                    
                case .Active:
                    break
                    
                case .Complete:
                    break
                    
                case .ConfirmClientPayment:
                    break
                    
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeClientRequest() {
        requestOrder
            .asObservable()
            .subscribe(onNext: { [weak self] (order) in
                guard let strongSelf = self, order != nil else { return }
                switch strongSelf.requestedPosted {
                case true:
                    strongSelf.startTimer()
                    
                case false:
                    guard let newRequest = order else { return }
                    strongSelf.postRequestToDB(newRequest)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func startTimer() {
        let interval = Date().timeIntervalSince1970
        UserDefaultsManager.saveRequestTimer(interval: interval) // deprc.
        
        Timer.scheduledTimer(withTimeInterval: 150.0, repeats: false) { [weak self] (_) in
            guard let strongSelf = self else { return }
            guard !strongSelf.timerDidLap else {
                strongSelf.checkRequestStatus(
                    strongSelf.requestOrder.value?.id,
                    restartTimer: strongSelf.timerDidLap
                )
                return
            }
            strongSelf.timerDidLap = true
            strongSelf.checkRequestStatus(strongSelf.requestOrder.value?.id, restartTimer: true)
        }
    }
    
    private func checkRequestStatus(_ id: String?, restartTimer: Bool) {
        guard let requestId = id else { return }
        let api = NetworkManager.instance
        api.checkRequestState(from: requestId) { [weak self] in
            guard let strongSelf = self else { return }
            
            switch $0 {
            case .NewClientRequest:
                restartTimer ? strongSelf.startTimer() : ()

            default:
                strongSelf.requestState.accept($0)
            }
        }
    }
    
    private func postRequestToDB(_ model: RequestOrderModel) {
        let api = NetworkManager.instance
        api.postRequest(model, status: model.requestStatus) { [weak self] (success, objectId, error) in
            guard let strongSelf = self, error == nil, success == true, objectId != nil
                else {
                    print("Error Happened On Post Request")
                    return
            }
            strongSelf.requestedPosted = true
            
            guard var req = strongSelf.requestOrder.value else { return }
            req.id = objectId ?? ""
            req.requestStatus = RequestState.RequestPending.rawValue
            strongSelf.requestOrder.accept(req)
        }
    }
    
    private func obtainExpertApproval() {
        expertDidApprove
            .share()
            .bind(to: shouldDismiss)
            .disposed(by: disposeBag)
        
        expertDidApprove
            .map { $0 }
            .subscribe(onNext: { [weak self] (didApprove) in
                guard didApprove == true else { return }
                self?.requestState.accept(.ExpertAccepted)
            })
            .disposed(by: disposeBag)
        
        needForExpertApproval.accept(true)
    }
}
