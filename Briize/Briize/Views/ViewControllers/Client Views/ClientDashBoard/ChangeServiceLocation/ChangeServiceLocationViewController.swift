//
//  ChangeServiceLocationViewController.swift
//  Briize
//
//  Created by Admin on 7/16/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

class ChangeServiceLocationViewController: GMSAutocompleteViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension ChangeServiceLocationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "")")
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
       self.navigationController?.popViewController(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
