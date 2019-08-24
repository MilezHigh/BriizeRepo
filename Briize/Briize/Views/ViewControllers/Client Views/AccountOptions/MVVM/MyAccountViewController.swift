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

public var kLogout: Bool = false

class  MyAccountViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
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
    fileprivate let dispoebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        self.navBar.topItem?.titleView = v
        
        self.profileImageView.layer.borderWidth = 2.0
        self.profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        self.profileImageView.image = self.profileImage
        
        self.options
            .asObservable()
            .bind(
                to: self.clientSettingsCollectionView.rx.items(
                    cellIdentifier: "clientOption",
                    cellType: MyAccountCollectionViewCell.self)
            ) { row, model, cell in
                cell.model = [model.key:model.value]
            }
            .disposed(by: self.dispoebag)
        
        self.clientSettingsCollectionView.rx
            .itemSelected
            .subscribe(
                onNext: { [weak self] indexPath in
                    guard let strongSelf = self else {return}
                    strongSelf.clientSettingsCollectionView.deselectItem(at: indexPath, animated: true)
                    
                    let cell = strongSelf.clientSettingsCollectionView.cellForItem(at: indexPath) as! MyAccountCollectionViewCell
                    switch cell.accountOptionLabel.text {
                    case "Support":
                        strongSelf.showMailComposer()
                    case "Logout":
                        kLogout = true
                        strongSelf.dismiss(animated: true, completion: nil)
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
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["Briizebeauty@gmail.com"])
            composeVC.setSubject("User Support")
            composeVC.setMessageBody("How may we assist you?", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
