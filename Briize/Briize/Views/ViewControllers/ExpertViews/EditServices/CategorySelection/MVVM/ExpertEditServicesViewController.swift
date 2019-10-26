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

public protocol PricingDelegate: AnyObject {
    var add: (( _ price: Int, _ toIndex: IndexPath, _ name: String) -> Void)? { get set }
}

class ExpertEditServicesViewController: UIViewController, PricingDelegate {
    
    @IBOutlet weak var editServiceTableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let offered = BriizeManager.shared.user.model.value?.servicesOffered
    private let approvedFor = BriizeManager.shared.user.model.value?.servicesApprovedFor
    
    private var selectedId: Int = 0
    
    private var sections: [ServiceDatasource] {
        let offerd = offered ?? []
        
        /// 1. Find relevant categories
        let _mutable = ServiceDatasource.servicesOfferedByExpert()
        let mutable = _mutable.filter ({
            let services = $0.services
            return offerd.filter({ dic in
                let id = dic["serviceId"]
                return services.filter({ s in
                    let isMatch = s.id == id as? Int
                    return isMatch
                }).first != nil
            }).first != nil
        }).compactMap({ $0 })
        
        /// 2. Find current user services
        let filteredServices = mutable.map({ $0.services })
        let userServices = filteredServices.map({ service in
            offerd.map({ o -> ServiceObject? in
                var filteredService = service.filter({ s in
                    s.id == o["serviceId"] as? Int
                }).first
                filteredService?.price = o["cost"] as? Int ?? 0
                return filteredService
            }).compactMap({ $0 })
        }).compactMap({ $0 })
        
        /// 3. Join & Display
        var count = 0
        let sources = mutable.map ({ value -> ServiceDatasource in
            var objs = value
            objs.services = userServices[count]
            count += 1
            return objs
        })
        
        return sources
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
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.popViewController(animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                strongSelf.editServiceTableView.beginUpdates()
                strongSelf.editServiceTableView.deleteRows(at: [index], with: .fade)
                strongSelf.editServiceTableView.insertRows(at: [index], with: .fade)
                strongSelf.editServiceTableView.endUpdates()
                
                guard let cell = strongSelf.editServiceTableView.cellForRow(at: index) as? ServicesEditedTableViewCell else { return }
                cell.model = ServiceObject(id: strongSelf.selectedId, name: name, price: price)
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
            .flatMap ({ [weak self] (index) -> Observable<UIViewController> in
                (self?.showPriceSelection(from: index) ?? .just(UIViewController()))
            })
            .subscribe(onNext: { [weak self] (vc) in
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func showPriceSelection(from index: IndexPath) -> Observable<UIViewController> {
        self.editServiceTableView.deselectRow(at: index, animated: true)
        
        guard let cell = self.editServiceTableView.cellForRow(at: index) as? ServicesEditedTableViewCell,
            
            let vc = UIStoryboard(name: "ExpertFlow", bundle: nil)
                .instantiateViewController(withIdentifier: "PriceSelectorViewController")
                as? PriceSelectorViewController
            
            else { fatalError("Missing UI: ExpertFlow Storyboard") }
        
        self.selectedId = cell.model?.id ?? 0
        let serviceName = cell.textLabel?.text ?? ""
        
        vc.delegate = self
        vc.indexPath = index
        vc.nameOfService = serviceName
                        
        let viewController = vc
        return .just(viewController)
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
