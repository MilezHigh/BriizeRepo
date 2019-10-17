//
//  ExpertCompletedViewController.swift
//  Briize
//
//  Created by Miles Fishman on 10/12/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ExpertCompletedViewController: UIViewController {
    
    @IBOutlet weak var ordersTable: UITableView!
    
    private var disposeBag = DisposeBag()
    
    var viewModel: ExpertCompletedViewModel? {
        didSet {
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel = ExpertCompletedViewModel()
    }
    
    deinit {
        print("Deinit - \(self.description)")
    }
}
    
extension ExpertCompletedViewController {
    
    private func bind() {
        guard ordersTable.delegate == nil else { return }
            
        viewModel?
            .requests
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: ordersTable.rx.items(
                cellIdentifier: "priorCompletedRequest",
                cellType      : UITableViewCell.self
                )
            ) ({ _, model, cell in
                let image = UIImage(named:"briizeRequestIcon")
                cell.imageView?.image = image
                cell.imageView?.downloadedFromAPI(with: model.clientID, isClient: false)
                cell.imageView?.layer.masksToBounds = true
                cell.imageView?.clipsToBounds = true
                cell.imageView?.layer.cornerRadius = cell.imageView?.frame.width ?? 0 / 2
                cell.selectionStyle = .none
                cell.textLabel?.text = model.clientFullName
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text =
                    "- Service: \(model.serviceType)\n\n"
                    + "- Cost: $\(model.cost).00\n\n"
                    + "- You Made: $\(model.payToExpert).00\n"
            })
            .disposed(by: disposeBag)
        
        ordersTable
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
}

extension ExpertCompletedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let header = UITableViewHeaderFooterView()
        header.tintColor = .white
        header.textLabel?.numberOfLines = 0
        header.textLabel?.text = "Completed Beauty Requests"
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
}
