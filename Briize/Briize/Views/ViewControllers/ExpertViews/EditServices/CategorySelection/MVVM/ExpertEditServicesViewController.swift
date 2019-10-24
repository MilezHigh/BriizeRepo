//
//  ExpertEditServicesViewController.swift
//  Briize
//
//  Created by Miles Fishman on 9/24/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public protocol Pricing: AnyObject {
    var add: (( _ price: Int, _ toIndex: IndexPath, _ name: String) -> Void)? { get set }
}

class ExpertEditServicesViewController: UIViewController, Pricing {
    
    @IBOutlet weak var editServiceTableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let offered = BriizeManager.shared.user.model.value?.servicesOffered
    private let approvedFor = BriizeManager.shared.user.model.value?.servicesApprovedFor
    
    private var selectedId: Int = 0
    
    private var sections: [ServiceDatasource] {
        let offerd = offered ?? []
        var mutable = ServiceDatasource.allServices().filter ({
            let services = $0.services
            return !offerd.filter({ dic in
                !services.filter({ s in
                    s.id == dic["serviceId"] as? Int
                }).isEmpty
            }).isEmpty
        }).compactMap({ $0 })
        
        let filteredCategory = mutable.first
        let filteredServices = filteredCategory?.services.filter({ s in
            !offerd.filter({ o in
                s.id == o["serviceId"] as? Int
            }).isEmpty
        }) ?? []
        
        mutable = mutable.map ({
            var obj = $0
            obj.services = filteredServices
            return obj
        })
        return mutable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProtocol()
        bindServices()
        checkExpertApprovedServices()
    }
    
    /// Pricing Protocol
    var add: ((Int, IndexPath, String) -> Void)?
}

extension ExpertEditServicesViewController {
    
    private func configureProtocol() {
        add = { [weak self] price, index, name in
            self?.navigationController?.popViewController(animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.editServiceTableView.beginUpdates()
                self?.editServiceTableView.deleteRows(at: [index], with: .automatic)
                self?.editServiceTableView.insertRows(at: [index], with: .automatic)
                self?.editServiceTableView.endUpdates()
                
                guard let cell = self?.editServiceTableView
                    .dequeueReusableCell(withIdentifier: "ServicesEditedTableViewCell", for: index)
                    as? ServicesEditedTableViewCell
                    else { return }
                
                cell.model = ServiceObject(id: self?.selectedId ?? 0, name: name , price: price)
            }
        }
    }
    
    private func bindServices() {
        editServiceTableView.delegate = self
        editServiceTableView.dataSource = self
        editServiceTableView.tableFooterView = UIView()
        editServiceTableView
            .rx
            .itemSelected
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (index) in
                self?.editServiceTableView
                    .deselectRow(at: index, animated: true)
                
                guard
                    let cell = self?.editServiceTableView
                        .dequeueReusableCell(withIdentifier: "ServicesEditedTableViewCell", for: index)
                        as? ServicesEditedTableViewCell,
                    
                    let vc = UIStoryboard(name: "ExpertFlow", bundle: nil)
                        .instantiateViewController(withIdentifier: "PriceSelectorViewController")
                        as? PriceSelectorViewController
                    
                    else { return }
                
                self?.selectedId = cell.model?.id ?? 0
                
                vc.delegate = self
                vc.indexPath = index
                vc.nameOfService = cell.textLabel?.text
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkExpertApprovedServices() {
        guard let o = offered, let a = approvedFor else { return }
        print("\n*\nServices Offered: \n\(o)\n\n Approved For: \(a)\n*\n")
    }
}

extension ExpertEditServicesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "ServicesEditedTableViewCell", for: indexPath)
            as? ServicesEditedTableViewCell
        
        let secs = sections
        let service = secs[indexPath.section]
        let model = service.services[indexPath.row]
        cell?.model = model
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.tintColor = .white
        header.textLabel?.textColor = .briizePink
        header.textLabel?.text = sections[section].name
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
