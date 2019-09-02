//
//  SignUpNowViewController.swift
//  Briize
//
//  Created by Miles Fishman on 8/27/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SignUpNowViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var certificationImageView: UIImageView!
    @IBOutlet weak var submitNextButton: UIButton!
    @IBOutlet weak var addCertButton: UIButton!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!

    var viewModel: SignUpViewModel = SignUpViewModel()

    private var imagePicker: UIImagePickerController!

    private let expandedHeight: CGFloat = 150.0
    private let disposeBag = DisposeBag()

    private var localImageData: Data? {
        didSet {
            guard let data = localImageData else { return }
            certificationImageView.image = UIImage(data: data)
            addCertButton.setTitle("", for: .normal)
        }
    }
    private var isSigningUpAsExpert: Bool {
        return segmentController.selectedSegmentIndex == 1
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ApplyForServicesViewController else { return }
        destination.selectedServices = { [weak self] ids in
            self?.submitUser(selectedServiceIds: ids)
        }
    }
    
    @IBAction func segmentSelected(_ sender: Any) {
        let height: CGFloat = isSigningUpAsExpert ? expandedHeight : 0
        let title: String = isSigningUpAsExpert ? "Next" : "Sign Up"

        UIView.animate(withDuration: 0.3) {
            self.imageViewHeight.constant = height
            self.addCertButton.isHidden = !self.isSigningUpAsExpert
            self.submitNextButton.setTitle(title, for: .normal)
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func addCertButtonPressed(_ sender: Any) {
        chooseImageSourceAlertFrom()
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        submitUser()
    }

    func submitUser(selectedServiceIds: [Int] = []) {
        let user = UserPartialModel(
            firstName: firstNameTextField.text ?? "",
            lastName : lastNameTextField.text ?? "",
            email    : emailTextField.text ?? "",
            phone    : phoneTextField.text ?? "",
            password : passwordTextField.text ?? "",
            certImageData: localImageData,
            servicesAppliedFor: selectedServiceIds.compactMap({ $0.description })
        )

        switch isSigningUpAsExpert && selectedServiceIds.isEmpty {
        case true:
            self.performSegue(withIdentifier: "applyForServiceSegue", sender: self)

        case false:
            viewModel.signUpUser(model: user)
        }
    }
}

// MARK: - Helpers
extension SignUpNowViewController {

    private func setup() {
        navigationController?.navigationBar.isHidden = false
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v

        submitNextButton.layer.cornerRadius = 25
        certificationImageView.layer.cornerRadius = 12

        setupTextFields()
        segmentSelected(self)
    }

    private func bind() {
        viewModel
            .signUpSuccess
            .asDriver()
            .drive( onNext: { [weak self] in
                guard $0.0 else { return }
                self?.navigationController?.navigationBar.isHidden = true
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                [firstNameTextField.rx.text,
                 lastNameTextField.rx.text,
                 emailTextField.rx.text,
                 phoneTextField.rx.text,
                 passwordTextField.rx.text]
            )
            .asObservable()
            .flatMap({ values -> Observable<Bool> in
                return .just(values
                    .filter({ $0 == "" || $0 == nil })
                    .isEmpty ? true : false)
            })
            .do( onNext: { [weak self] in
                self?.addCertButton.alpha = $0 ? 1 : 0.5
                self?.submitNextButton.alpha = $0 ? 1 : 0.5
            })
            .bind(to: submitNextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func setupTextFields() {
        let fields: [UITextField] = [
            firstNameTextField,
            lastNameTextField,
            emailTextField,
            phoneTextField,
            passwordTextField
        ]

        _ = fields.map ({
            $0.delegate = self
            $0.borderStyle = .none
            $0.addBottomBorderToTextField()

            var string: String = ""
            switch $0 {
            case firstNameTextField:
                string = "First Name"

            case lastNameTextField:
                string = "Last Name"

            case emailTextField:
                string = "Email"

            case phoneTextField:
                string = "Phone"

            case passwordTextField:
                string = "Password"

            default:
                break
            }

            $0.attributedPlaceholder = NSAttributedString(
                string    : string,
                attributes: [ .foregroundColor : UIColor.darkText ]
            )
        })
    }
}

// MARK: - TextField Delegate
extension SignUpNowViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIPicker Methods
extension SignUpNowViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true)

        localImageData = (
            info [convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
            )?
            .jpegData(compressionQuality: 0.7)
    }

    private func takePhoto(from imageSource: ImageSource) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        switch imageSource {
        case .camera:
            imagePicker.sourceType = .camera

        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }

    private func chooseImageSourceAlertFrom() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (_) in
            self?.takePhoto(from: .camera)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] (_) in
            self?.takePhoto(from: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}
