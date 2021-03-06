//
//  ServiceSelectionViewController.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
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

    var selectedServices: [SelectedService] = []
    
    let viewModel = ServiceSelectionViewModel()

    private var servicesChosen: [ServiceSubType] = []

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        bindCategoryUI()
        bindCategoryServices()
        bindCollectionviewConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sessionManager.adoptController(self)
        self.sessionManager.persistedSegueId.accept("waiting")
    }
    
    deinit {
        print("deinit success - \(self.description)")
    }
    
    @IBAction func closeViewControllerPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if selectedServices.isEmpty {
            let alert = UIAlertController(title: "You must select at least one service", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            sessionManager
                .user
                .searchExpertsWithTheseServices
                .accept(selectedServices.map({ return $0.id }))
            
            switch sessionManager.requestType.value {
            case .Live:
                self.performSegue(withIdentifier: "searchExpertsSegue", sender: self)
                
            case .Custom:
                self.performSegue(withIdentifier: "customRequestSegue", sender: self)
            }
        }
    }
    
}

extension ServiceSelectionViewController {
    
    private func setupVC() {
        selectedServicesTableview.delegate = self
        selectedServicesTableview.dataSource = self
        selectedServicesTableview.tableFooterView = UIView()
        
        submitButton.backgroundColor = .white
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = UIColor.briizePink.cgColor
        submitButton.layer.cornerRadius = 10
        
        categoryImageView.layer.cornerRadius = 20
        categoryImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryImageView.darkOverlay()
    }
    
    private func bindCategoryUI() {
        self.sessionManager
            .user
            .selectedCategoryName
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        self.sessionManager
            .user
            .selectedCategoryImage
            .bind(to: categoryImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func bindCategoryServices() {
        viewModel
            .services
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: serviceCollectionView.rx.items(
                cellIdentifier: "serviceCell",
                cellType: ServiceCollectionViewCell.self
                )
            ) ({ _, service, cell in
                cell.service = service
            })
            .disposed(by: disposeBag)
        
        serviceCollectionView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionviewConfiguration() {
        //serviceCollectionView.delegate = self
        serviceCollectionView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.serviceCollectionView
                    .deselectItem(at: $0, animated: true)
                
                guard let cell = strongSelf.serviceCollectionView
                    .cellForItem(at: $0) as? ServiceCollectionViewCell else { return }
                
                strongSelf.process(cell, with: $0)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func process(_ cell: ServiceCollectionViewCell, with indexPath: IndexPath) {
        let name = cell.service!.name
        let wasNotSelected = cell.alpha == 1
        let hasSubTypes = !(cell.service?.subTypes.isEmpty)!
        
        if hasSubTypes && wasNotSelected {
            let actionSheet = showSubTypeSelectionActionSheet(cell.service!.subTypes, indexPath: indexPath)
            self.present(actionSheet, animated: true, completion: nil)
        }
        else if wasNotSelected {
            processServiceSelection(id: cell.service!.id, title: name, subType: name, subTypeExists: false, with: indexPath)
        }
        else {
            removeSelectedServices(cell)
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
        _ = actions
            .map({ sheet.addAction($0) })

        return sheet
    }
    
    private func subTypeAction(with subType: ServiceSubType, indexPath: IndexPath) -> UIAlertAction {
        let action = UIAlertAction(
            title: subType.rawValue,
            style: .default
        ) { [weak self] (_) in
            guard let strongSelf = self else { return }

            let cell = strongSelf.serviceCollectionView
                .cellForItem(at: indexPath) as! ServiceCollectionViewCell

            strongSelf.processServiceSelection(
                id: subType.id,
                title: cell.service!.name,
                subType: subType.rawValue,
                subTypeExists: true,
                with: indexPath
            )
        }
        return action
    }
    
    private func processServiceSelection(id: Int, title: String, subType: String, subTypeExists: Bool, with indexPath: IndexPath) {
        let cell = serviceCollectionView.cellForItem(at: indexPath) as! ServiceCollectionViewCell
        let subType = subTypeExists ? subType : title
        let selected = SelectedService(id: id, type: title, subtype: subType)
        selectedServices.append(selected)
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                cell.alpha = cell.alpha != 0.5 ? 0.5 : 1
        },
            completion: { _ in
                self.selectedServicesTableview.reloadData()
        })
    }
    
    private func removeSelectedServices(_ cell: ServiceCollectionViewCell) {
        selectedServices.removeAll(where: {
            $0.type == cell.service!.name
        })
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                cell.alpha = 1.0
        },
            completion: { _ in
                self.selectedServicesTableview.reloadData()
        })
    }
}

extension ServiceSelectionViewController:
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        let size = UIScreen.main.bounds.width <= 375 ?
            CGSize(width: 90, height: 90) : CGSize(width: 100, height: 100.0)
        return size
    }
}

extension ServiceSelectionViewController:
UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "selectedService",
            for: indexPath
        )
        cell.textLabel?.text = selectedServices[indexPath.row].subtype
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedServices.count
    }
}

