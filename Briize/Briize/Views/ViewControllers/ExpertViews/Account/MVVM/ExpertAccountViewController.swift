//
//  ExpertAccountViewController.swift
//  Briize
//
//  Created by Miles Fishman on 9/11/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import RxSwift
import RxCocoa

class ExpertAccountViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var bgExpertProfileImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var expertProfileImageView: UIImageView!
    @IBOutlet weak var expertNameLabel: UILabel!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var clientAmountLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var ratingAmountLabel: UILabel!
    @IBOutlet weak var accountOptionsCollectionView: UICollectionView!
    @IBOutlet weak var offlineLabel: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel = ExpertAccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setup()
        self.bind()
        self.bindTableConfig()
        
        bgExpertProfileImageView.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ExpertAccountViewController {
    
    func setupNavigationBar(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        self.navigationItem.titleView = v
    }
    
    func setup(){
        guard let user = BriizeManager.shared.user.model.value, let urlString = user.urlString?.url else {return}
       
        self.bgExpertProfileImageView.gradientOverlay()
        
        self.expertProfileImageView.layer.borderWidth = 3
        self.expertProfileImageView.layer.borderColor = UIColor.white.cgColor
        self.expertProfileImageView.layer.cornerRadius = self.expertProfileImageView.bounds.width/2
        
        self.statsView.layer.borderWidth = 1.0
        self.statsView.layer.borderColor = UIColor.white.cgColor
        self.statsView.layer.cornerRadius = 6
        
        self.expertNameLabel.text = user.name
        self.ratingAmountLabel.text = user.rating?.description ?? "5/5"
        
        self.expertProfileImageView.downloadedFrom(link: urlString, setProfileImage: true)
        
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.viewHistory))
        leftBarButton.tintColor = .black
        self.navigationItem.leftBarButtonItems = [leftBarButton]
    }
    
    func bind(){
        Observable.just(self.viewModel.accountOptions.value)
            .observeOn(MainScheduler.instance)
            .bind(
                to: self.accountOptionsCollectionView.rx
                    .items(cellIdentifier: "expertOption",
                           cellType: ExpertAccountOptionsCollectionCell.self)
            ) { index, option, cell in
                cell.model = option
            }
            .disposed(by: self.disposeBag)
        
        self.accountOptionsCollectionView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    func bindTableConfig(){
        self.accountOptionsCollectionView.rx
            .itemSelected
            .subscribe(
                onNext: { [weak self] (index) in
                    guard let cell = self?.accountOptionsCollectionView.cellForItem(at: index) as? ExpertAccountOptionsCollectionCell,
                        let strongSelf = self
                        else {return}
                    
                    strongSelf.accountOptionsCollectionView.deselectItem(at: index, animated: false)
                    strongSelf.handleItemSelected(cell)
                },
                onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
    }
}

extension ExpertAccountViewController {
    
    func handleItemSelected(_ cell: ExpertAccountOptionsCollectionCell) {
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 0.5
        }
            ,completion: { (_) in
                UIView.animate(withDuration: 0.1, animations: {
                    cell.alpha = 1.0
                }
                    ,completion: { (_) in
                        switch cell.optionTitle.text! {
                        case "Support":
                            self.handleSupport()
                            
                        case "Log-Out":
                            self.handleLogout()
                            
                        default:
                            self.performSegue(withIdentifier: cell.segueID, sender: self)
                        }
                })
        })
    }
    
    func handleSupport(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Briizebeauty@gmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func handleLogout(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func viewHistory() {
        
    }
}

extension ExpertAccountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
        -> CGSize {
            switch self.view.frame.height < 812 {
            case true:
                return CGSize(width: collectionView.frame.width - 80, height: collectionView.frame.height - 80)
                
            case false:
                return CGSize(width: collectionView.frame.width - 130, height: collectionView.frame.height - 130)
            }
    }
}

extension ExpertAccountViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
