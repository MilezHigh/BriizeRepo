//
//  LoginViewController.swift
//  Briize
//
//  Created by Miles Fishman on 6/28/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

// - Major changes:
// Apple Pay / Stripe - Integrate
// Instagram approval - Privacy Policy google drive link
// Twilio Account Config. - Amount of phone nbumbers under account

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
        self.setup()
        self.setupTextViews()
        self.setupBGVideo()
        self.bindSegueSignal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupVC()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        print("Deinit - \(self.description)")
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        player.pause()
        showLoader()
        viewModel.logIn(username: usernameTextfield.text!, password: passwordTextfield.text!)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "SignUp", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }
}

extension LoginViewController {
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func setup() {
        self.navigationController?.navigationBar.isHidden = true

        usernameTextfield.text = "miles.fishman@yahoo.com"//"briizebeauty@gmail.com"
        passwordTextfield.text = "devguy123"//"theboss123"

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)

        goButton.layer.cornerRadius = 10
        goButton.layer.borderColor = UIColor.briizePink.cgColor
        goButton.layer.borderWidth = 1
        goButton.backgroundColor = .white
    }

    private func scanState() {
        BriizeManager.shared.adoptController(nil)
        
        setupVideoObserver()

        guard
            let username = UserDefaults.standard.value(forKey: "Username") as? String,
            let password = UserDefaults.standard.value(forKey: "Password") as? String
            else { return }
        
        usernameTextfield.text = username
        passwordTextfield.text = password

        goButtonPressed(())
    }

    // MARK: - BG Video Methods
    fileprivate func setupVideoObserver() {
        player.play()
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(playerItemReachedEnd(notification:)),
                name    : NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object  : player.currentItem
        )
    }
    
    fileprivate func setupBGVideo() {
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0.6
        
        guard let url = Bundle.main.url(forResource : "briizeBGV", withExtension: "mp4") else { return }
        player = AVPlayer.init(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = self.view.layer.frame
        player.actionAtItemEnd = .none
        player.play()
        
        self.view.layer.insertSublayer(self.playerLayer, at: 0)
        self.view.insertSubview(overlay, at: 1)
    }
    
    @objc func playerItemReachedEnd(notification: NSNotification) {
        player.seek(to: CMTime.zero)
    }
    
    fileprivate func cleanupVC() {
        NotificationCenter.default.removeObserver(self)
        player.pause()
        viewModel.userSegueIdSignal.accept("waiting")
    }
    
    fileprivate func setupTextViews() {
        usernameTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )

        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )

        usernameTextfield.borderStyle = UITextField.BorderStyle.none
        passwordTextfield.borderStyle = UITextField.BorderStyle.none

        usernameTextfield.addBottomBorderToTextField(color: .white)
        passwordTextfield.addBottomBorderToTextField(color: .white)
    }
    
    fileprivate func bindSegueSignal() {
        viewModel
            .userSegueIdSignal
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (signalName) in
                    switch signalName {
                    case "waiting":
                        break

                    default:
                        self?.setLoaderMessage(message: "Complete!")
                        self?.dismissLoader()
                        self?.dismiss(animated: true, completion: {
                            BriizeManager.shared.persistedAppState
                                .accept((.authenticated, signalName))
                        })
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
