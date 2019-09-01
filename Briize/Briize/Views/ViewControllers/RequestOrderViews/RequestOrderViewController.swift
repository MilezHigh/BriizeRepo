//
//  RequestOrderViewController.swift
//  Briize
//
//  Created by Miles Fishman on 4/30/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RequestOrderViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var cheackEtaButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var instaGramButton: UIButton!
    @IBOutlet weak var thirdOptionButton: UIButton! /// <---  Not Assigned
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var masterBottomView: UIView!

    //MARK:- Variables
    var viewModel: RequestOrderViewModel?
    
    //MARK:- Private Variables
    private let disposeBag = DisposeBag()
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupUIDrivers()
    }
    
    // MARK:- Helpers
    private func setupNavigationBar() {
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v
    }
    
    private func setupUI() {
        masterView.layer.cornerRadius = 12
        masterBottomView.layer.cornerRadius = 12
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        cheackEtaButton.layer.cornerRadius = 26
        cancelButton.layer.cornerRadius = 26
        completeButton.layer.cornerRadius = 30
        
        guard let userId = viewModel?.requestOrder.value?.expertID else { return }
        userImageView.downloadedFromAPI(with: userId)
        
        guard let state = viewModel?.requestState.value else { return }
        let isActive = state == .Active
        completeButton.backgroundColor = isActive ? .green : .lightGray
        completeButton.isEnabled = isActive
    }
    
    private func setupUIDrivers() {
        viewModel?
            .requestOrder
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 != nil ? self?.updateUI(from: $0!) : ()
            })
            .disposed(by: disposeBag)
        
        viewModel?
            .shouldDismiss
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 ? self?.dismiss(animated: true) : ()
            })
            .disposed(by: disposeBag)
        
        viewModel?
            .needForExpertApproval
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 ? self?.obtainExpertApproval() : ()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(from requestOrder: RequestOrderModel) {
        priceLabel.text = " " + " $\(requestOrder.cost.description)"
        
        guard let userIsExpert = sessionManager.user.model.value?.isExpert else { return }
        nameLabel.text = userIsExpert ? requestOrder.clientFullName : requestOrder.expertFullname
        
        titleLabel.text = userIsExpert ? "Your Client:" : "Your Expert:"
        
        guard let status = RequestState.init(rawValue: requestOrder.requestStatus) else { return }
        statusLabel.text = " " + status.userFriendlyMessage
        
        var services: String = ""
        _ = requestOrder.serviceIds.map {
            print("Service ID - " + $0.description)
            services += ServiceSubType.serviceNameFor(id: $0) + " | "
        }
        servicesLabel.text = " " + requestOrder.serviceType + " - " + services
    }
    
    private func obtainExpertApproval() {
        let alert = UIAlertController(title: "Would you like to accept this client's request?", message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "Accept", style: .default) { [weak self] (action) in
            self?.processExpertApproval(didApprove: true)
        }
        let deny = UIAlertAction(title: "Deny", style: .destructive) { [weak self] (action) in
            self?.processExpertApproval(didApprove: false)
        }
        alert.addAction(accept)
        alert.addAction(deny)
        present(alert, animated: true)
    }
    
    private func processExpertApproval(didApprove: Bool) {
        viewModel?.expertDidApprove.accept(didApprove)
    }
    
    // MARK:- Button Actions
    @IBAction func checkEtaPressed(_ sender: Any) {
        //viewModel.CheckRequestStatus w/ ETA
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        //handle cancel state
    }
    
    @IBAction func completePressed(_ sender: Any) {
        //find userType
    }
    
    @IBAction func instagramPressed(_ sender: Any) {
        // Instagram Expert
    }
    
    @IBAction func messagesPressed(_ sender: Any) {
        // Twilio Expert / Client
    }
    
    @IBAction func thirdOptionPressed(_ sender: Any) {
        // Not Assigned
    }
}
