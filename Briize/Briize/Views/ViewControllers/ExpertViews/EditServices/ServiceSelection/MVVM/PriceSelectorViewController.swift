//
//  ServicesForCategoryViewController.swift
//  Briize
//
//  Created by Miles Fishman on 9/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Parse


class PriceSelectorViewController: UIViewController {
    
    @IBOutlet weak var priceTextField: UITextField!
    
    weak var delegate: PricingDelegate?
    
    public var indexPath: IndexPath?
    public var nameOfService: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a Price for \(nameOfService)"
        priceTextField.text = ""
        priceTextField.delegate = self
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(selectedPrice))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([doneButton, spaceButton], animated: false)
        
        self.priceTextField.inputAccessoryView = toolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        priceTextField.becomeFirstResponder()
    }
    
    @objc func selectedPrice() {
        priceTextField.resignFirstResponder()
        
        // put into viewModel - Miles!
        guard let idxPath = indexPath else { fatalError("IndexPath must be injected") }
        
        let text = priceTextField.text?.replacingOccurrences(of: "$", with: "") ?? ""
        let number = Int(text) ?? 0
        BriizeManager.shared.showLoader("Saving \nService: \(nameOfService) \nPrice: $\(number)")
        
        var newValue: [String: Int] = [:]
        let currentelyOffered = BriizeManager.shared.user.model.value?.servicesOffered ?? []
        let id = ServiceSubType(rawValue: nameOfService)?.id ?? 0
        newValue["serviceId"] = id
        newValue["cost"] = number
        
        var obj: [String : [NSDictionary]] = ["data": []]
        var offers = currentelyOffered.filter({ ($0["serviceId"] as? Int) != id })
        offers += [NSMutableDictionary(dictionary: newValue)]
        obj["data"] = offers
        
        guard let user = PFUser.current() else { return }
        user["servicesOffered"] = obj
        user.saveInBackground { (complete, error) in
            guard error == nil, complete else {
                print(error?.localizedDescription ?? "Incomplete Save to Database")
                return
            }
            
            //completion on self - Miles!
            let services = obj["data"]?.compactMap({ NSMutableDictionary(dictionary: $0) }) ?? []
            DispatchQueue.main.async { [weak self] in
                var userLocalModel = BriizeManager.shared.user.model.value
                userLocalModel?.servicesOffered = services
                
                guard let model = userLocalModel else { return }
                BriizeManager.shared.user.model.accept(model)
                BriizeManager.shared.dismissloader()
                
                self?.delegate?.add?(number, idxPath, self?.nameOfService ?? "")
            }
        }
    }
    
    deinit {
        print("deinit - success")
    }
}

extension PriceSelectorViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.contains("$") == false {
            textField.text = "$" + (textField.text ?? "")
        }
    }
}
