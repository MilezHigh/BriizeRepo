//
//  ExpertTableViewCell.swift
//  Briize
//
//  Created by Admin on 5/19/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Parse

class ExpertTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expertProfileImageView: UIImageView!
    
    @IBOutlet weak var requestButtonOutlet  : UIButton!
    @IBOutlet weak var messageButtonOutlet  : UIButton!
    @IBOutlet weak var instagramButtonOutlet: UIButton!
    
    @IBOutlet weak var expertName       : UILabel!
    @IBOutlet weak var expertPrice      : UILabel!
    @IBOutlet weak var expertDistance   : UILabel!
    
    @IBOutlet weak var ratingImageView1: UIImageView!
    @IBOutlet weak var ratingImageView2: UIImageView!
    @IBOutlet weak var ratingImageView3: UIImageView!
    @IBOutlet weak var ratingImageView4: UIImageView!
    @IBOutlet weak var ratingImageView5: UIImageView!
    
    let datePicker = UIDatePicker()
    
    var textField = UITextField(frame: CGRect(x: 0, y: 0, width: 150.0, height: 80))
    
    var expertImage: UIImage?
    
    var model: UserModel? {
        didSet {
            guard let model = model, let url = model.urlString?.url else {return}
            // calculate rating to display correct number of stars in image views
            // model.rating?.description
            self.expertName.text = model.name
            self.expertPrice.text = model.price
            self.expertDistance.text = model.distance
            
            guard self.expertProfileImageView.image == nil else { return }
            self.expertImage = self.expertImage == nil ? NetworkManager.convertUrlStringToImageSync(url) : self.expertImage
            self.expertProfileImageView.image = expertImage
        }
    }
    
    // MARK: Lifestyle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hero.id = "expertHeroImage"
        self.expertProfileImageView.layer.cornerRadius = expertProfileImageView.bounds.width/2
        self.requestButtonOutlet.layer.cornerRadius = 25
        self.messageButtonOutlet.layer.cornerRadius = 25
        self.instagramButtonOutlet.layer.cornerRadius = 25
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Button Actions
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        guard var topController = UIApplication.shared.keyWindow?.rootViewController else {return}
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Request Now", style: .default) { (action) in
            let sanitizedNumberText = self.model?.price.filter({ $0 != "$" })
            guard let cost = Int(sanitizedNumberText ?? "0") else { return }
            let profit = cost / 10 /// <--- 10% Commission
            
            let requestOrder = RequestOrderModel(
                id: nil,
                clientID: BriizeManager.shared.user.model.value?.id ?? "",
                clientFullName: BriizeManager.shared.user.model.value?.name ?? "",
                expertID: self.model?.id ?? "",
                expertFullname: self.model?.name ?? "",
                serviceType: BriizeManager.shared.user.selectedCategoryName.value,
                serviceIds: BriizeManager.shared.user.searchExpertsWithTheseServices.value.filter({ $0 != 0 }),
                address: "",
                startTime: nil,
                finishTime: nil,
                requestStatus: RequestState.ClientRequested.rawValue,
                cost: cost,
                payToExpert: cost - profit,
                profit: profit
            )
            guard let requestOrderVC = BriizeRouter.RequestOrderVC else { return }
            requestOrderVC.viewModel = RequestOrderViewModel(requestOrder, state: .ClientRequested)
            
            BriizeManager.shared.liveController.value?.navigationController?
                .present(UINavigationController(rootViewController: requestOrderVC), animated: true)
        }
        let action2 = UIAlertAction(title: "Schedule Request", style: .default) { (action) in
            self.showDatePickerVC(topController)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        
        topController.present(actionSheet, animated: true)
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func instagramButtonPressed(_ sender: Any) {
        
        
    }
}

extension ExpertTableViewCell {
    
    func showDatePickerVC(_ sender: UIViewController){
           BriizeManager.shared.user.openSelectaDateForRequest.accept(true)
        }
}


