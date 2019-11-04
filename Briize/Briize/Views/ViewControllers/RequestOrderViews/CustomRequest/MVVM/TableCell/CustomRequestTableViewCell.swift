//
//  CustomRequestTableViewCell.swift
//  Briize
//
//  Created by Miles Fishman on 10/30/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import UIKit

class CustomRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var clientImageView: UIImageView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var startingAmount: UILabel!
    
    var model: RequestOrderModel? {
        didSet {
            DispatchQueue.main.async {
                guard let model = self.model else { return }
                self.clientImageView.downloadedFromAPI(with: model.clientID, isClient: true)
                self.clientNameLabel.text = model.clientFullName
                self.dateLabel.text = "03/11/2020"
                self.startingAmount.text = "$" + model.clientAskingPrice.description
                self.serviceLabel.text = model.serviceIds
                    .map({ ServiceSubType.serviceNameFor(id: $0) })
                    .joined(separator: ", ")
            }
        }
    }
}
