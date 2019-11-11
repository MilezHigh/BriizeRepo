//
//  AccountPriorCollectionCell.swift
//  Briize
//
//  Created by Miles Fishman on 11/13/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Parse

class AccountPriorCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var priorRequestsTableView: UITableView!
    
    fileprivate var priorRequests: [RequestOrderModel] = []
    fileprivate var customRequests: [RequestOrderModel] = []
    fileprivate var users: [UserModel] = []
    
    var model: ClientAccountCellModel? {
        didSet{
            guard let model = model else {return}
            priorRequests = model.priorRequests
            
            priorRequestsTableView.delegate = self
            priorRequestsTableView.dataSource = self
            priorRequestsTableView.tableFooterView = UIView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let userID = PFUser.current()?.objectId else { return }
        pullPriorRequests(for: userID)
    }
}

extension AccountPriorCollectionCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        let title = section == 0 ? "History" : "Custom Requests"
        view.textLabel?.text = title
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorRequests.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
            
        default:
            return 80
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "priorRequestCell")
            cell == nil ? (cell = UITableViewCell(style: .subtitle, reuseIdentifier: "priorRequestCell")) : ()
            return cell
            
        default:
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "priorRequestCell")
            cell == nil ? (cell = UITableViewCell(style: .subtitle, reuseIdentifier: "priorRequestCell")) : ()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let image = UIImage(named:"briizeRequestIcon")
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = image
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = cell.imageView?.frame.width ?? 0 / 2
        
        switch indexPath.section {
        case 0:
            if priorRequests.count > 0 {
                let object = priorRequests[indexPath.row]
                cell.selectionStyle = .none
                cell.textLabel?.text = object.expertFullname
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text = object.serviceType
                    + "\n$" + object.cost.description
                    + "\n" + (object.createdAt?.description ?? "")
                
                cell.imageView?.downloadedFromAPI(with: object.expertID, isClient: false)
            }
            
        case 1:
            if customRequests.count > 0 {
                let object = customRequests[indexPath.row]
                cell.selectionStyle = .none
                cell.textLabel?.text = object.serviceType
                cell.detailTextLabel?.text = "$"
                    + object.clientAskingPrice.description
                    + " \nBids: " + object.bids.count.description
                
                cell.imageView?.downloadedFromAPI(with: object.clientID, isClient: false)
            }
            
        default:
            break
        }
    }
}

extension AccountPriorCollectionCell {
    
    func pullPriorRequests(for userID: String) {
        let network = NetworkManager.instance
        network.pullRequests(for: userID) { [weak self] (models) in
            self?.priorRequests = models.compactMap({ $0 })
            
            DispatchQueue.global(qos: .utility).async {
                network.pullRequests(type: "Custom", userId: userID) { [weak self] (requests) in
                    if requests.count > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
                            self?.customRequests = requests.compactMap({ $0 })
                            self?.priorRequestsTableView.reloadData()
                        })
                    }
                }
            }
        }
    }
}
