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
    @IBOutlet weak var browseCustomResultsButton: UIButton!
    
    let rosePink = UIColor(red: 223.0/255.0, green: 163.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel = ExpertAccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setup()
        self.bind()
        self.bindTableConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let leftBarButton = UIBarButtonItem(
            barButtonSystemItem: .bookmarks,
            target             : self,
            action             : #selector(self.viewHistory)
        )
        leftBarButton.tintColor = rosePink
        leftBarButton.isEnabled = true
        navigationItem.leftBarButtonItems = [leftBarButton]
        
        let rightBarButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target             : self,
            action             : #selector(self.searchCustomRequests)
        )
        rightBarButton.tintColor = rosePink
        rightBarButton.isEnabled = true
        navigationItem.rightBarButtonItems = [rightBarButton]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ExpertAccountViewController {
    
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
    
    func setup(){
        guard let user = sessionManager.user.model.value,
            let urlString = user.urlString?.url else { return }
        
        browseCustomResultsButton.layer.cornerRadius = browseCustomResultsButton.bounds.height / 2
        
        expertProfileImageView.layer.borderWidth = 1
        expertProfileImageView.layer.borderColor = UIColor.white.cgColor
        expertProfileImageView.layer.cornerRadius = expertProfileImageView.bounds.width / 2
        expertProfileImageView.downloadedFrom(link: urlString, setProfileImage: true)
        
        statsView.layer.borderWidth = 1.0
        statsView.layer.borderColor = UIColor.white.cgColor
        statsView.layer.cornerRadius = 6
        
        expertNameLabel.text = user.name
        ratingAmountLabel.text = user.rating?.description ?? "5/5"
    }
    
    func bind(){
        accountOptionsCollectionView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable
            .just(viewModel.accountOptions.value)
            .observeOn(MainScheduler.instance)
            .bind(to: accountOptionsCollectionView.rx.items(
                cellIdentifier: "expertOption",
                cellType      : ExpertAccountOptionsCollectionCell.self
                )
            ) ({ _, option, cell in
                cell.model = option
            })
            .disposed(by: disposeBag)
        
        viewModel
            .checkForExistingRequests()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] (requests) in
                guard let requestOrder = requests.first,
                    let requestOrderVC = BriizeRouter.RequestOrderVC,
                    let strongSelf = self
                    else { return }
                
                let requestStatus = RequestState.create(from: requestOrder.requestStatus)
                requestOrderVC.viewModel = RequestOrderViewModel(requestOrder, state: requestStatus)
                strongSelf
                    .navigationController?
                    .present(UINavigationController(rootViewController: requestOrderVC), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bindTableConfig(){
        accountOptionsCollectionView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] (index) in
                guard let strongSelf = self,
                    let cell = strongSelf.accountOptionsCollectionView.cellForItem(at: index)
                        as? ExpertAccountOptionsCollectionCell else { return }
                
                strongSelf.accountOptionsCollectionView.deselectItem(at: index, animated: false)
                strongSelf.handleItemSelected(cell)
            })
            .disposed(by: disposeBag)
    }
}

extension ExpertAccountViewController {
    
    func handleItemSelected(_ cell: ExpertAccountOptionsCollectionCell) {
        UIView.animate(
            withDuration: 0.1,
            animations  : { cell.alpha = 0.5 },
            completion  : { _ in
                UIView.animate(
                    withDuration: 0.1,
                    animations  : { cell.alpha = 1.0 },
                    completion  : { _ in
                        switch cell.optionTitle.text ?? "" {
                        case "Support"  : self.handleSupport()
                        case "Log-Out"  : self.handleLogout()
                        default         : self.performSegue(withIdentifier: cell.segueID, sender: self)
                        }
                })
        })
    }
    
    func handleSupport(){
        guard MFMailComposeViewController.canSendMail() else {
            print("Can't Display Email Screen")
            return
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["Briizebeauty@gmail.com"])
        mail.setMessageBody("<p>How may we assist?</p>", isHTML: true)
        present(mail, animated: true)
    }
    
    func handleLogout(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func viewHistory() {
        performSegue(withIdentifier: "showExpertsCompletedOrders", sender: self)
    }
    
    @objc func searchCustomRequests() {
        performSegue(withIdentifier: "", sender: self)
    }
}

extension ExpertAccountViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView           : UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
    ) -> CGSize {
        //let isBelow = view.frame.height <= 812
        let padding: CGFloat = 80
        return CGSize(
            width: collectionView.frame.width - padding,
            height: collectionView.frame.height - padding
        )
    }
}

extension ExpertAccountViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller        : MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error               : Error?
    ) {
        print(
            error?.localizedDescription ??
            "** ERROR:\n Mail Compose Delegate Method -> 'didFinishWith result'\n**"
        )
        controller.dismiss(animated: true)
    }
}
