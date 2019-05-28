//
//  LoginViewController.swift
//  Briize
//
//  Created by Miles Fishman on 6/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import RxSwift
import RxCocoa
import Parse
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var gl: CAGradientLayer!
    
    private let disposebag = DisposeBag()
    private let viewModel = LoginViewModel()
    
    fileprivate var player  : AVPlayer!
    fileprivate var playerLayer : AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoom)
        
        self.setup()
        self.setupTextViews()
        self.setupBGVideo()
        self.bindSegueSignal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupVideoObserver()
        
        BriizeManager.shared.adoptController(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cleanupVC()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        self.player.pause()
        self.showLoader()
        self.viewModel.logIn(username: self.usernameTextfield.text!, password: self.passwordTextfield.text!)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }
}

extension LoginViewController {
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    fileprivate func setup(){
        
        // - dev testing :
        self.usernameTextfield.text = "miles.fishman@yahoo.com"
        self.passwordTextfield.text = "devguy123"
        //
        
        self.navigationController?.navigationBar.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)

        self.goButton.layer.cornerRadius = 25
    }
    
    // Background Video Methods
    fileprivate func setupVideoObserver() {
        player.play()
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(playerItemReachedEnd(notification:)),
                name    : NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object  : self.player.currentItem
        )
    }
    
    fileprivate func setupBGVideo() {
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.6
        
        let url = Bundle.main.url(forResource : "briizeBGV", withExtension: "mp4")
        self.player = AVPlayer.init(url: url!)
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.playerLayer.frame = self.view.layer.frame
        
        self.player.actionAtItemEnd = .none
        self.player.play()
        
        self.view.layer.insertSublayer(self.playerLayer, at: 0)
        self.view.insertSubview(overlay, at: 1)
    }
    
    @objc func playerItemReachedEnd(notification: NSNotification) {
        self.player.seek(to: CMTime.zero)
    }
    
    fileprivate func cleanupVC() {
        NotificationCenter.default.removeObserver(self)
        
        self.player.pause()
        self.viewModel.userSegueIdSignal.accept("waiting")
    }
    
    fileprivate func setupTextViews() {
        self.usernameTextfield.borderStyle = UITextField.BorderStyle.none
        self.passwordTextfield.borderStyle = UITextField.BorderStyle.none
        self.usernameTextfield.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.passwordTextfield.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.addBottomBorderToTextField(myTextField: self.usernameTextfield)
        self.addBottomBorderToTextField(myTextField: self.passwordTextfield)
    }
    
    fileprivate func addBottomBorderToTextField(myTextField:UITextField) {
        let bottomLine   = CALayer()
        bottomLine.frame = CGRect(
            x:0.0,y: myTextField.frame.height - 1,
            width  : self.view.frame.width - 40,
            height : 1.0
        )
        bottomLine.backgroundColor = UIColor.white.cgColor
        
        myTextField.borderStyle = UITextField.BorderStyle.none
        myTextField.layer.addSublayer(bottomLine)
    }
    
    fileprivate func bindSegueSignal() {
        viewModel
            .userSegueIdSignal
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (signalName) in
                    guard let this = self else {return}
                    
                    switch signalName {
                    case "waiting":
                        break
                        
                    default:
                        this.setLoaderMessage(message: "Complete!")
                        this.dismissLoader()
                        this.performSegue(withIdentifier: signalName, sender: this)
                    }
                },
                onError: { (error) in
                    print(error.localizedDescription)
            })
            .disposed(by: self.disposebag)
    }
}

extension LoginViewController: NVActivityIndicatorViewable {
    
    fileprivate func showLoader() {
        BriizeManager.shared.showLoader()
    }
    
    fileprivate func setLoaderMessage(message: String) {
        BriizeManager.shared.setLoaderMessage(message: message)
    }
    
    fileprivate func dismissLoader() {
        BriizeManager.shared.dismissloader()
    }
}
