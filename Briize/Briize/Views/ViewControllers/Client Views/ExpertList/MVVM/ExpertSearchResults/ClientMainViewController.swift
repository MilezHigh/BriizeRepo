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
//import Mapbox
import GooglePlaces

class ClientMainViewController: UIViewController {
    @IBOutlet weak var expertTableView: UITableView!
    
    var overlay: UIView?
    
    private var segmentControl = UISegmentedControl(items: ["List", "Map"])
    
    private let viewModel = ClientMainViewModel()
    private let disposeBag = DisposeBag()
    private let myError = BehaviorRelay<Error?>(value:nil)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        bindErrorHandling()
        bindServicesToSearch()
        
        sessionManager
            .user
            .openSelectaDateForRequest
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 == true ? self?.performSegue(withIdentifier: "showSelectADate", sender: self) : ()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentControl.selectedSegmentIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ExpertMapListViewController",
            let dest = segue.destination as? ExpertMapListViewController
            else { return }
        
        let users = (viewModel.experts.value
            .first?.items
            .map({ $0 }) ?? [])
            .map({ $0.model })
            .compactMap({ $0 })
        
        let viewModel = ExpertMapListViewModel(experts: users)
        dest.viewModel = viewModel
    }
}

//MARK: - UI Helper Methods
extension ClientMainViewController {

    private func configureViews() {
        let button = UIBarButtonItem(
            barButtonSystemItem: .action,
            target:self,
            action: #selector(openChangePickupLocation)
        )
        let button2 = UIBarButtonItem(
            barButtonSystemItem: .search,
            target:self,
            action: #selector(choseMapView)
        )
        navigationItem.rightBarButtonItems = [button2, button]
        navigationController?.view.backgroundColor = .white
        
        expertTableView.backgroundColor = .white
        expertTableView.tableFooterView = UIView()
    }
    
    @objc func choseMapView() {
        performSegue(withIdentifier: "ExpertMapListViewController", sender: self)
    }
    
    @objc func openChangePickupLocation() {
        //        let autocompleteController = GMSAutocompleteViewController()
        //        autocompleteController.delegate = self
        //        present(autocompleteController, animated: true, completion: nil)
        performSegue(withIdentifier: "showChangeLocationVC", sender: self)
    }
    
    private func showLoader() {
        sessionManager.showLoader("Finding Experts...")
    }
    
    private func hideLoader() {
        sessionManager.dismissloader()
    }
}

// MARK: - ViewModel Binding Methods
extension ClientMainViewController {
    
    private func bindErrorHandling() {
        myError
            .asDriver()
            .drive(onNext: { (error) in print(error ?? "No errors") })
            .disposed(by: self.disposeBag)
    }
    
    private func bindServicesToSearch() {
        sessionManager
            .user
            .searchExpertsWithTheseServices
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (services) in
                services.isEmpty ? print("No Services to search") : ()
                
                self?.showLoader()
                self?.bindExperts(withServices: services)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindExperts(withServices: [Int]) {
        expertTableView.dataSource = nil
        expertTableView.delegate   = nil
        
        viewModel.demoFindObjects(with: withServices)
        
        let datasource = viewModel.dataSource()
        viewModel
            .experts
            .asDriver()
            .do(onNext: { [weak self] (models) in !models.isEmpty ? self?.hideLoader() : () })
            .drive( self.expertTableView.rx.items(dataSource: datasource))
            .disposed(by: self.disposeBag)
        
        expertTableView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
}

//MARK: - Tableview Delegate
extension ClientMainViewController: UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
}

//MARK: - Google Places Delegate
extension ClientMainViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}
