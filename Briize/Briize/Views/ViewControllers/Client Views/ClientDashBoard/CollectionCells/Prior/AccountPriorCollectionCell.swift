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
    
    fileprivate var priorRequests:[RequestOrderModel] = []
    fileprivate var users:[UserModel] = []
    
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
        
        guard let userID = PFUser.current()?.objectId else {return}
        pullPriorRequests(for: userID)
    }
}

extension AccountPriorCollectionCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "priorRequestCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "priorRequestCell")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if priorRequests.count > 0 {
            let object = priorRequests[indexPath.row]
            let image = UIImage(named:"briizeRequestIcon")
            
            cell.selectionStyle = .none
            cell.textLabel?.text = object.expertFullname
            cell.detailTextLabel?.text = object.serviceType + " | " + object.address
            cell.imageView?.image = image
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = cell.imageView?.frame.width ?? 0 / 2
            cell.imageView?.downloadedFromAPI(with: object.expertID, isClient: false)
        }
    }
}

extension AccountPriorCollectionCell {
    
    func pullPriorRequests(for userID: String) {
        let network = NetworkManager.instance
        network.pullRequests(for: userID) { (models) in
            if models.count > 0 {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.2,
                    execute : { [weak self] in
                        //                        let nonNilModels = models.compactMap({ $0 })
                        //                        print(nonNilModels)
                        
                        self?.priorRequests = models.compactMap({ $0 })
                        self?.priorRequestsTableView.reloadData()
                })
            }
        }
    }
}
