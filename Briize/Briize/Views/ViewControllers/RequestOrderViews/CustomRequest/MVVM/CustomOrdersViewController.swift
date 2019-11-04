//
//  CustomOrdersViewController.swift
//  Briize
//
//  Created by Miles Fishman on 10/29/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CustomOrdersViewController: UIViewController, PricingDelegate {
    
    @IBOutlet weak var requestTableView: UITableView!
    
    var viewModel: CustomOrdersViewModel?

    var editingCell: CustomRequestTableViewCell?
    
    var didLoad: Bool = false
    
    /// Pricing Protocol
    var add: ((Int, IndexPath, String) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProtocol()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didLoad {
            didLoad = true
            bind()
        }
    }
    
    func setupNavigationBar() {
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
    
    private func bind() {
        requestTableView.tableFooterView = UIView()
        requestTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel?
            .requests
            .asObservable()
            .bind(to: requestTableView.rx.items(
                cellIdentifier: "CustomRequestTableViewCell",
                cellType      : CustomRequestTableViewCell.self
                )
            ) ({ row, model, cell in
                cell.model = model
            })
            .disposed(by: disposeBag)
    }
}

extension CustomOrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.tintColor = .white
        header.textLabel?.textColor = .briizePink
        header.textLabel?.text = "Custom Orders Nearby"
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 130
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let bidAction = UITableViewRowAction(style: .normal, title: "Bid") { [weak self] (action, index) in
            guard let vc = self?.showPriceSelection(from: index) as? PriceSelectorViewController else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        bidAction.backgroundColor = UIColor.briizePink
        return [bidAction]
    }
    
    private func showPriceSelection(from index: IndexPath) -> UIViewController{
        requestTableView.deselectRow(at: index, animated: true)
        
        guard
            let cell = self.requestTableView
                .cellForRow(at: index) as? CustomRequestTableViewCell,
            
            let vc = UIStoryboard(name: "PriceSelection", bundle: nil)
                .instantiateInitialViewController() as? PriceSelectorViewController
            
            else { fatalError("Missing - PriceSelection Storyboard") }
        
        editingCell = cell
        
        vc.delegate = self
        vc.indexPath = index
        vc.nameOfService = "Bidding Amount"
        return vc
    }
    
    private func configureProtocol() {
        add = { [weak self] price, index, name in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.popViewController(animated: true)
            
            BriizeManager.shared.showLoader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                guard var model = self?.editingCell?.model else { return }
                let id = BriizeManager.shared.user.model.value?.id ?? ""
                model.bids += [[ "\(id)" : "\(price)" ]]
                NetworkManager.instance.postRequest(model, status: model.requestStatus) { (done, id, err) in
                    DispatchQueue.main.async {
                        BriizeManager.shared.dismissloader()
                        
                        guard err == nil else { return }
                        self?.viewModel?.fetchRequests()
                    }
                }
            }
        }
    }
}
