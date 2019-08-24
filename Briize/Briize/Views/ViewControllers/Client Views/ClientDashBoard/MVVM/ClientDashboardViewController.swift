//
//  CategoryViewController.swift
//  Briize
//
//  Created by Miles Fishman on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NVActivityIndicatorView

class ClientDashboardViewController: UIViewController {
    
    @IBOutlet weak var menuSegmentBar: UISegmentedControl!
    @IBOutlet weak var leftUserMenuProfilePicBarButton: UIBarButtonItem!
    @IBOutlet weak var accountCollectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    let viewModel = ClientDashboardViewModel()
    
    var serviceImage: UIImage?
    var profileImage: UIImage?
    var serviceTitle: String?
    var completedSetup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHero()
        self.setupNavigationBar()
        self.setupSegmentBar()
        self.bindSegueSignal()
        self.bindCategories()
        self.registerCells()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupLeftBarButton()
        
        self.sessionManager.liveController.accept(self)
        
        if kLogout == true {
            kLogout = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let title = self.serviceTitle,
            let img = self.serviceImage else { return }
        
        switch segue.destination {
        case is ServiceSelectionViewController:
            let chosenCategory = CategoryModel(name: title, image: img)
            let services = ServiceModel.addServicesToCategory(chosenCategory)
            guard let destination = segue.destination as? ServiceSelectionViewController else { return }
            destination.viewModel.services.accept(services)
            
        default:
            break
        }
    }
    
    deinit {
        print("deinit success - \(self.description)")
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        self.menuSegmentBar.changeUnderlinePosition()
        self.accountCollectionView.scrollToItem(
            at: IndexPath(item: sender.selectedSegmentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true)
    }
}

extension ClientDashboardViewController {
    
    private func setupHero() {
 
    }
    
    private func setupNavigationBar() {
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        self.navigationItem.titleView = v
    }
    
    private func setupSegmentBar() {
        self.menuSegmentBar.addUnderlineForSelectedSegment()
    }
    
    private func setupLeftBarButton(){
        if self.completedSetup == false {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(userTappedMenuImage))
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            let imgV = UIImageView(frame: v.frame)
            imgV.contentMode = .scaleAspectFill
            imgV.clipsToBounds = true
            imgV.downloadedFrom(link: self.viewModel.user.value!.urlString!.url!, setProfileImage: true)
            imgV.isUserInteractionEnabled = true
            imgV.layer.cornerRadius = 15
            
            v.layer.cornerRadius = 15
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(gesture)
            v.addSubview(imgV)
            
            self.leftUserMenuProfilePicBarButton.image = nil
            self.leftUserMenuProfilePicBarButton.customView = v
            self.leftUserMenuProfilePicBarButton.customView?.isUserInteractionEnabled = true
            
            self.completedSetup = true
        }
    }
    
    private func bindCategories() {
        self.accountCollectionView.layer.cornerRadius = 15
        self.accountCollectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.2)
        
        let datasource = ClientDashboardViewController.dataSource()
        self.viewModel.options
            .asObservable()
            .bind(to: self.accountCollectionView.rx.items(dataSource: datasource))
            .disposed(by: self.disposeBag)
        
        self.accountCollectionView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    private func bindSegueSignal() {
        self.viewModel.segueSignal
            .asDriver()
            .drive(
                onNext:{  [weak self] (id) in
                    guard id != "waiting" else { return }
                    self?.performSegue(withIdentifier: id, sender: self)
                },
                onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
    }
    
    private func registerCells() {
        self.accountCollectionView
            .register(UINib(nibName: "AccountPriorCollectionCell", bundle: nil),
                      forCellWithReuseIdentifier: "Account_Prior")
        self.accountCollectionView
            .register(UINib(nibName: "AccountLiveRequestsCollectionCell", bundle: nil),
                      forCellWithReuseIdentifier: "Account_Live")
    }
}

extension ClientDashboardViewController: NVActivityIndicatorViewable {
    
    fileprivate func showLoader() {
        self.sessionManager.showLoader("Loading...")
    }
    
    fileprivate func dismissLoader() {
        self.sessionManager.dismissloader()
    }
}

extension ClientDashboardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(
        _ collectionView           : UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
        )
        -> CGSize {
            let height = collectionView.bounds.height - 75
            let width = collectionView.bounds.width
            return CGSize(width: width, height: height)
    }
}

extension ClientDashboardViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.centerCollectionView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.centerCollectionView()
        }
    }
    
    func centerCollectionView() {
        let centerPoint = self.view.convert(view.center, to: self.accountCollectionView)
        guard let centerIndex = self.accountCollectionView.indexPathForItem(at: centerPoint) else {return}
        self.accountCollectionView.scrollToItem(at: centerIndex, at: .centeredHorizontally, animated: true)
        self.menuSegmentBar.selectedSegmentIndex = centerIndex.row
        self.menuSegmentBar.changeUnderlinePosition()
    }
}

extension ClientDashboardViewController {
    
    @objc func userTappedMenuImage(){
        let storyboard = UIStoryboard(name: "ClientFlow", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "myAccount") as? MyAccountViewController
        self.present(controller!, animated: true)
    }
}
