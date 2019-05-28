//
//  ServiceSelectionViewController.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Hero
import RxSwift
import RxCocoa
import AudioToolbox

class ServiceSelectionViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var serviceCollectionView: UICollectionView!
    @IBOutlet weak var selectedServicesTableview: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    typealias SelectedService = (id: Int, type: String, subtype: String)
    
    private let disposeBag = DisposeBag()
    
    let viewModel = ServiceSelectionViewModel()
    
    private var servicesChosen:[ServiceSubType] = []
    
    var selectedServices: [SelectedService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        self.bindCategoryUI()
        self.bindCategoryServices()
        self.bindCollectionviewConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sessionManager.adoptController(self)
        self.navigationController?.hero.isEnabled = true
    }
    
    deinit {
        print("deinit success - \(self.description)")
    }
    
    @IBAction func closeViewControllerPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if self.selectedServices.isEmpty {
            let alert = UIAlertController(title: "You must select at least one service", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            switch self.sessionManager.requestType.value {
            case .Live:
                self.sessionManager.user.searchExpertsWithTheseServices.accept(self.selectedServices.map({ return $0.id }))
                self.performSegue(withIdentifier: "searchExpertsSegue", sender: self)
                
            case .Custom:
                self.performSegue(withIdentifier: "customRequestSegue", sender: self)
            }
        }
    }
    
}

extension ServiceSelectionViewController {
    
    private func setupVC() {
        self.hero.isEnabled = true
        
        self.selectedServicesTableview.delegate = self
        self.selectedServicesTableview.dataSource = self
        self.selectedServicesTableview.tableFooterView = UIView()
        
        self.categoryImageView.darkOverlay()
        self.categoryImageView.hero.id = "\(kHeroImage)"
    }
    
    private func bindCategoryUI() {
        self.sessionManager.user.selectedCategoryName
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.disposeBag)
        
        self.sessionManager.user.selectedCategoryImage
            .bind(to: self.categoryImageView.rx.image)
            .disposed(by: self.disposeBag)
    }
    
    private func bindCategoryServices() {
        self.viewModel.services
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind(
                to: self.serviceCollectionView.rx.items(
                    cellIdentifier : "serviceCell",
                    cellType       : ServiceCollectionViewCell.self)
                )
            { _, service, cell in
                cell.service = service
            }
            .disposed(by: self.disposeBag)
        
        self.serviceCollectionView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    private func bindCollectionviewConfiguration() {
        self.serviceCollectionView.delegate = self
        self.serviceCollectionView.rx
            .itemSelected
            .subscribe(
                onNext: { [weak self] indexPath in
                    guard let strongSelf = self else {return}
                    strongSelf.serviceCollectionView.deselectItem(at: indexPath, animated: true)
                    
                    let cell = strongSelf.serviceCollectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                    strongSelf.process(cell, with: indexPath)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func process(_ cell: ServiceCollectionViewCell, with indexPath: IndexPath) {
        let name = cell.service!.name
        let wasNotSelected = cell.alpha == 1
        let hasSubTypes = !(cell.service?.subTypes.isEmpty)!
        
        if hasSubTypes && wasNotSelected {
            let actionSheet = self.showSubTypeSelectionActionSheet(cell.service!.subTypes, indexPath: indexPath)
            self.present(actionSheet, animated: true, completion: nil)
        }
        else if wasNotSelected {
            self.processServiceSelection(id: cell.service!.id, title: name, subType: name, subTypeExists: false, with: indexPath)
        }
        else {
            self.removeSelectedServices(cell)
        }
    }
    
    private func showSubTypeSelectionActionSheet(_ subTypesToShow: [ServiceSubType], indexPath: IndexPath) -> UIAlertController {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        sheet.addAction(cancel)
        
        let actions = subTypesToShow
            .map({ subType -> UIAlertAction in
                return self.subTypeAction(with: subType, indexPath: indexPath)
            })
        _ = actions.map({ sheet.addAction($0) })
        
        return sheet
    }
    
    private func subTypeAction(with subType: ServiceSubType, indexPath: IndexPath) -> UIAlertAction {
        let action = UIAlertAction(
            title: subType.rawValue,
            style: .default) { [weak self] (_) in
                guard let strongSelf = self else { return }
                let cell = strongSelf.serviceCollectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
                strongSelf.processServiceSelection(id: subType.id, title: cell.service!.name, subType: subType.rawValue, subTypeExists: true, with: indexPath)
        }
        return action
    }
    
    private func processServiceSelection(id: Int, title: String, subType: String, subTypeExists: Bool, with indexPath: IndexPath) {
        let cell = self.serviceCollectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
        let subType = subTypeExists ? subType : title
        let selected = SelectedService(id: id, cell.service!.name, subType)
        self.selectedServices.append(selected)
        
        DispatchQueue.main.async {
            self.selectedServicesTableview.reloadData()
            
            UIView.animate(withDuration: 0.3, animations: {
                cell.alpha = cell.alpha != 0.5 ? 0.5 : 1
            })
        }
    }
    
    private func removeSelectedServices(_ cell: ServiceCollectionViewCell) {
        self.selectedServices.removeAll(where: { $0.type == cell.service!.name })
        
        DispatchQueue.main.async {
            self.selectedServicesTableview.reloadData()
            
            UIView.animate(withDuration: 0.6, animations: {
                cell.alpha = 1.0
            })
        }
    }
}

extension ServiceSelectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            return CGSize(width: 100, height: 100.0)
    }
}

extension ServiceSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedService", for: indexPath)
        cell.textLabel?.text = self.selectedServices[indexPath.row].subtype
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedServices.count
    }
}

