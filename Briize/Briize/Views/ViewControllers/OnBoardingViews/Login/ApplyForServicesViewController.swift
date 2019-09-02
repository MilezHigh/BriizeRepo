//
//  ApplyForServicesViewController.swift
//  Briize
//
//  Created by Miles Fishman on 8/31/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ApplyForServicesViewController: UIViewController {
    
    @IBOutlet weak var servicesTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!

    var selectedServices: (([Int]) -> ())?

    let sections: [ServiceDatasource] = ServiceDatasource.allServices()

    private let serviceIds = BehaviorRelay<[Int]>(value: [])
    private let disposebag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    private func setup() {
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        doneButton.layer.cornerRadius = 25
    }

    private func bind() {
        serviceIds
            .asObservable()
            .flatMap({ value -> Observable<Bool> in
                return .just(!value.isEmpty)
            })
            .flatMap({ [weak self] isEnabled -> Observable<Bool> in
                self?.doneButton.alpha = isEnabled ? 1 : 0.5
                return .just(isEnabled)
            })
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: disposebag)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        selectedServices?(serviceIds.value)
    }
}

extension ApplyForServicesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applyForServiceTableCell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].services[indexPath.row].name
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let model = sections[indexPath.section].services[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
        let wasSelected = serviceIds.value.contains(model.id)
        cell.accessoryType = wasSelected ? .none : .checkmark

        var ids = serviceIds.value
        guard wasSelected else {
            ids.append(model.id)
            serviceIds.accept(ids)
            return
        }
        ids.removeAll(where: {
            $0 == model.id
        })
        serviceIds.accept(ids)
    }
}
