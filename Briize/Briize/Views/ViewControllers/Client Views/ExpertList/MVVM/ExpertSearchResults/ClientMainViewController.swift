//
//  ViewController.swift
//  Briize
//
//  Created by Miles Fishman on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Hero
//import Mapbox
import GooglePlaces

class ClientMainViewController: UIViewController {
    @IBOutlet weak var closeExpertTableButtonOutlet: UIButton!
    @IBOutlet weak var expertTableView: UITableView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    //var map: MGLMapView?
    var overlay: UIView?
    
    private var kExpertTableViewHeight: CGFloat = 189.0
    private var kExpertTableCellHeight: CGFloat = 188.0
    private var numberOfExpertsPulled: Int = 0
    
    private let viewModel = ClientMainViewModel()
    private let disposeBag = DisposeBag()
    private let myError = BehaviorRelay<Error?>(value:nil)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        self.setupVC()
        
        BriizeManager.shared.user
            .openSelectaDateForRequest
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 == true ? self?.performSegue(withIdentifier: "showSelectADate", sender: self) : ()
            })
            .disposed(by: self.disposeBag)
    }
    
    //MARK: - Button Actions
    
}

extension ClientMainViewController {
    
    //MARK: - UI Helper Methods
    
    private func setupVC() {
        self.navigationController?.hero.isEnabled = false
        
        self.configureViews()
        self.bindErrorHandling()
        self.bindServicesToSearch()
    }

    
    private func configureViews() {
        let segmentControl = UISegmentedControl(items: ["List", "Map"])
        segmentControl.frame = CGRect(x: 0, y: 0, width: 30.0, height: 20.0)
        segmentControl.contentMode = .scaleAspectFill
        segmentControl.tintColor = .black
        self.navigationItem.titleView = segmentControl
        
        let button = UIBarButtonItem(barButtonSystemItem: .action, target:self, action: #selector(openChangePickupLocation))
        self.navigationItem.rightBarButtonItem = button
        
        self.expertTableView.tableFooterView = UIView()
        self.expertTableView.backgroundColor = UIColor.white
    }
    
    @objc func openChangePickupLocation() {
        //        let autocompleteController = GMSAutocompleteViewController()
        //        autocompleteController.delegate = self
        //        present(autocompleteController, animated: true, completion: nil)
        self.performSegue(withIdentifier: "showChangeLocationVC", sender: self)
    }
    
    private func showLoader() {
        BriizeManager.shared.showLoader("Finding Experts...")
    }
    
    private func hideLoader() {
        BriizeManager.shared.dismissloader()
    }
}

extension ClientMainViewController {
    
    // MARK: - ViewModel Binding Methods
    
    private func bindErrorHandling() {
        self.myError
            .asDriver()
            .drive(
                onNext: { (error) in
                    print(error ?? "No errors")
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindServicesToSearch() {
        BriizeManager.shared.user
            .searchExpertsWithTheseServices
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (services) in
                    switch services.isEmpty {
                    case true:
                        print("No Services to search")
                        self?.showLoader()
                        self?.bindExperts(withServices: services)
                        
                    case false:
                        self?.showLoader()
                        self?.bindExperts(withServices: services)
                    }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindExperts(withServices: [Int]) {
        let datasource = self.viewModel.dataSource()
        
        self.expertTableView.dataSource = nil
        self.expertTableView.delegate   = nil
        
        self.viewModel.demoFindObjects(with: withServices)
        self.viewModel.experts
            .asDriver()
            .do(
                onNext: { [weak self] (models) in
                    if !models.isEmpty {
                        self?.hideLoader()
                    }
            })
            .drive( self.expertTableView.rx.items(dataSource: datasource))
            .disposed(by: self.disposeBag)
        
        self.expertTableView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
}

extension ClientMainViewController: UITableViewDelegate, UIScrollViewDelegate {
    
    //MARK: - Tableview Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension ClientMainViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "N/A")")
        //print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
