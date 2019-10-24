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
    
    var serviceImage  : UIImage?
    var profileImage  : UIImage?
    var serviceTitle  : String?
    var completedSetup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentBar()
        bindSegueSignal()
        bindCategories()
        bindLogout()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLeftBarButton()
        
        sessionManager.user.selectedCategoryServices.accept([])
        sessionManager.liveController.accept(self)
        
        if kLogout == true {
            kLogout = false
            viewModel.logout()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let title = serviceTitle,
            let img = serviceImage else { return }
        
        switch segue.destination {
        case is ServiceSelectionViewController:
            let chosenCategory = CategoryModel(name: title, image: img)
            let services = ServiceModel.addServicesToCategory(chosenCategory)
            guard let destination = segue
                .destination as? ServiceSelectionViewController else { return }
            destination.viewModel.services.accept(services)
            
        default:
            break
        }
    }
    
    deinit {
        print("deinit success - \(self.description)")
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        menuSegmentBar.changeUnderlinePosition()
        accountCollectionView.scrollToItem(
            at: IndexPath(item: sender.selectedSegmentIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

extension ClientDashboardViewController {
    
    private func setupNavigationBar() {
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: ""), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage(named: "")
    }
    
    private func setupSegmentBar() {
        menuSegmentBar.addUnderlineForSelectedSegment()
    }
    
    private func setupLeftBarButton(){
        if self.completedSetup == false {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(userTappedMenuImage))
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            let imgV = UIImageView(frame: v.frame)
            
            if let url = viewModel.user.value?.urlString?.url {
                imgV.downloadedFrom(link: url, setProfileImage: true)
            }
            imgV.contentMode = .scaleAspectFill
            imgV.clipsToBounds = true
            imgV.isUserInteractionEnabled = true
            imgV.layer.cornerRadius = 15
            
            v.layer.cornerRadius = 15
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(gesture)
            v.addSubview(imgV)
            
            leftUserMenuProfilePicBarButton.image = nil
            leftUserMenuProfilePicBarButton.customView = v
            leftUserMenuProfilePicBarButton.customView?.isUserInteractionEnabled = true
            
            completedSetup = true
        }
    }
    
    private func bindCategories() {
        accountCollectionView.layer.cornerRadius = 15
        accountCollectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.2)
        
        let datasource = ClientDashboardViewController.dataSource()
        viewModel
            .options
            .asObservable()
            .bind(to: accountCollectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        accountCollectionView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindSegueSignal() {
        viewModel
            .segueSignal
            .asDriver()
            .drive(onNext:{  [weak self] (id) in
                guard id != "waiting" else { return }
                self?.performSegue(withIdentifier: id, sender: self)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindLogout() {
        viewModel
            .loggedOut
            .asDriver()
            .drive(onNext: { [weak self] in
                $0 ? self?.dismiss(animated: true, completion: {
                    BriizeManager.shared.persistedAppState.accept((.loggedOut, ""))
                    BriizeManager.shared.dismissloader()
                }) : ()
            })
            .disposed(by: disposeBag)
    }
    
    private func registerCells() {
        accountCollectionView
            .register(UINib(nibName: "AccountPriorCollectionCell", bundle: nil),
                      forCellWithReuseIdentifier: "Account_Prior")
        accountCollectionView
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
    ) -> CGSize {
        let height = collectionView.bounds.height
        let width = collectionView.bounds.width
        return CGSize(width: width, height: height)
    }
}

extension ClientDashboardViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCollectionView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCollectionView()
        }
    }
    
    func centerCollectionView() {
        let centerPoint = self.view.convert(view.center, to: accountCollectionView)
        guard let centerIndex = accountCollectionView.indexPathForItem(at: centerPoint) else {return}
        accountCollectionView.scrollToItem(at: centerIndex, at: .centeredHorizontally, animated: true)
        menuSegmentBar.selectedSegmentIndex = centerIndex.row
        menuSegmentBar.changeUnderlinePosition()
    }
}

extension ClientDashboardViewController {
    
    @objc func userTappedMenuImage(){
        let storyboard = UIStoryboard(name: "ClientFlow", bundle: nil)
        guard let controller = storyboard
            .instantiateViewController(withIdentifier: "myAccount") as? MyAccountViewController
            else { return }
        
        self.present(controller, animated: true)
    }
}
