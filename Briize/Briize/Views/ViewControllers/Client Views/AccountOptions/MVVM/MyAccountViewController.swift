//
//  MyAccountViewController.swift
//  Briize
//
//  Created by Miles Fishman on 8/12/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MessageUI
import GooglePlaces

public var kLogout: Bool = false

class MyAccountViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var clientSettingsCollectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var profileImage: UIImage? = BriizeManager.shared.user.userProfileImage
    
    var options = BehaviorRelay<[String : String]>(value: [
            "Logout":"showLogout",
            "Support":"showSupport",
            "Custom Orders":"showPriorOrders",
            "Address":"showEditAddressModel"
    ])
    
    private let dispoebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sessionManager.adoptController(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.adoptController(self.presentingViewController)
    }

    private func setup() {
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navBar.topItem?.titleView = v
        
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.image = profileImage
        
        options
            .asObservable()
            .bind(
                to: clientSettingsCollectionView.rx.items(
                    cellIdentifier: "clientOption",
                    cellType      : MyAccountCollectionViewCell.self
                )
            ) ({ row, model, cell in
                cell.model = [model.key: model.value]
            })
            .disposed(by: self.dispoebag)
        
        clientSettingsCollectionView
            .rx
            .itemSelected
            .subscribe(
                onNext: { [weak self] indexPath in
                    guard let strongSelf = self else { return }
                    strongSelf.clientSettingsCollectionView
                        .deselectItem(at: indexPath, animated: true)
                    
                    guard let cell = strongSelf.clientSettingsCollectionView
                        .cellForItem(at: indexPath) as? MyAccountCollectionViewCell
                        else { return }
                    
                    switch cell.accountOptionLabel.text {
                    case "Support":
                        strongSelf.showMailComposer()
                        
                    case "Logout":
                        kLogout = true
                        guard let nav = strongSelf.presentingViewController as? UINavigationController,
                            let presenting = nav
                                .viewControllers
                                .map({ $0 as? ClientDashboardViewController })
                                .first
                            else { return }
                        
                        strongSelf.dismiss(animated: true) {
                            presenting?.viewModel.logout()
                        }
                        
                    case "Address":
                        strongSelf.showGooglePlacesPrompt()
                        
                    default:
                        break
                    }
                }
            )
            .disposed(by: self.dispoebag)
    }
    
    fileprivate func showMailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["Briizebeauty@gmail.com"])
            composeVC.setSubject("User Support")
            composeVC.setMessageBody("How may we assist you?", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    private func showGooglePlacesPrompt() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        if let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.addressComponents.rawValue) |
                UInt(GMSPlaceField.formattedAddress.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue)
            ) {
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter
            autocompleteController.placeFields = fields
            present(autocompleteController, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(
        _ controller        : MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error               : Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MyAccountViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: {
            BriizeManager.shared.changeAddressForCurrentUser(
                formatted: place.formattedAddress ?? "",
                state    : place.addressComponents?
                    .first(where: {
                        $0.types
                            .filter({ t in t == "administrative_area_level_1" })
                            .first != nil
                    })?
                    .name ?? "",
                
                zipcode  : place.addressComponents?
                    .first(where: {
                        $0.types
                            .filter({ t in t == "postal_code" })
                            .first != nil
                    })?
                    .name ?? ""
            )
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}

