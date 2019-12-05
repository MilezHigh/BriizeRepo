//
//  CustomRequestViewController.swift
//  Briize
//
//  Created by Miles Fishman on 3/21/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import Parse
import RxSwift
import RxCocoa

enum ImageSource {
    case camera
    case photoLibrary
}

class CustomRequestViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var leftPhotoButton: UIButton!
    @IBOutlet weak var rightPhotoButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var photosTitleLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var notesTitleLabel: UILabel!

    private enum ButtonSource {
        case left
        case right
    }

    private var imagePicker: UIImagePickerController!
    private var selectedButton: ButtonSource = .left

    private let viewModel = CustomRequestViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
        updateUIForDateSelection(hidePhotos: true)
    }

    deinit {
        print("deinit success - \(self.description)")
    }

    @IBAction func doneButtton(_ sender: Any) {
        updateUIForDateSelection(hidePhotos: false)
    }

    @IBAction func leftButtonPressed(_ sender: Any) {
        chooseImageSourceAlertFrom(buttonSource: .left)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        chooseImageSourceAlertFrom(buttonSource: .right)
    }

    @IBAction func submitAction(_ sender: Any) {
        let sanitizedText = priceLabel.text?.replacingOccurrences(of: "$", with: "") ?? "0"
        let clientAskingPrice = Int(sanitizedText) ?? 0
        let profit = (Int(sanitizedText) ?? 0) / 10

        let model = RequestOrderModel(
            id: "",
            type: "Custom",
            clientID: BriizeManager.shared.user.model.value?.id ?? "",
            clientFullName: BriizeManager.shared.user.model.value?.name ?? "",
            expertID: "",
            expertFullname: "",
            serviceType: BriizeManager.shared.user.selectedCategoryName.value,
            notes: notesTextView.text ?? "",
            serviceIds: BriizeManager.shared.user.searchExpertsWithTheseServices.value,
            bids: [],
            address: "",
            startTime: nil,
            finishTime: nil,
            scheduledDate: DateFormatter().date(from: dateTimeLabel.text ?? ""),
            requestStatus: RequestStatus.NewClientRequest.rawValue,
            cost: clientAskingPrice,
            payToExpert: clientAskingPrice - profit,
            profit: profit,
            clientAskingPrice: clientAskingPrice,
            beforeImage: PFFileObject(
                data: leftImageView.image?.jpegData(compressionQuality: 0.7) ?? Data(),
                                      contentType: "content/jpeg"),
            
            afterImage: PFFileObject(
                data: rightImageView.image?.jpegData(compressionQuality: 0.7) ?? Data(),
                contentType: "content/jpeg"),
            
            location: BriizeManager.shared.user.model.value?.currentLocation
        )
        viewModel.uploadCustomer(request: model)
    }
}

// MARK: - Helper Methods
extension CustomRequestViewController {
    
    private func bind() {
        viewModel
            .requestSubmitted
            .asDriver()
            .drive(onNext: { [weak self] in
                guard $0 else { return }
                self?.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)

        priceSlider.minimumValue = 0
        priceSlider.maximumValue = 1000
        priceSlider.value = 125
        priceSlider.rx.value
            .asObservable()
            .observeOn(MainScheduler.instance)
            .throttle(0.1, scheduler: MainScheduler.instance)
            .flatMap({ value -> Observable<Float> in
                return .just(round(value / 5) * 5)
            })
            .flatMap({ roundedValue -> Observable<String?> in
                return .just("$" + Int(roundedValue).description)
            })
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func updateUIForDateSelection(hidePhotos: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.photosTitleLabel.alpha = hidePhotos ? 0 : 1
            self.imageStackView.alpha = hidePhotos ? 0 : 1
            self.priceTitleLabel.alpha = hidePhotos ? 0 : 1
            self.priceLabel.alpha = hidePhotos ? 0 : 1
            self.priceSlider.alpha = hidePhotos ? 0 : 1
            self.notesTitleLabel.alpha = hidePhotos ? 0 : 1
            self.notesTextView.alpha = hidePhotos ? 0 : 1
            self.submitButton.alpha = hidePhotos ? 0 : 1
            self.datePicker.alpha = !hidePhotos ? 0 : 1
            self.doneButton.alpha = !hidePhotos ? 0 : 1

            self.photosTitleLabel.isHidden = hidePhotos
            self.imageStackView.isHidden = hidePhotos
            self.priceTitleLabel.isHidden = hidePhotos
            self.priceLabel.isHidden = hidePhotos
            self.priceSlider.isHidden = hidePhotos
            self.notesTitleLabel.isHidden = hidePhotos
            self.notesTextView.isHidden = hidePhotos
            self.submitButton.isHidden = hidePhotos
            self.doneButton.isHidden = !hidePhotos

            guard !hidePhotos else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, YYYY, h:mm a"
            self.dateTimeLabel.text = formatter.string(from: self.datePicker.date)
        }
    }

    @objc private func dateLabelTapped() {
        updateUIForDateSelection(hidePhotos: true)
    }

    private func setup() {
        doneButton.backgroundColor = .white
        doneButton.layer.borderWidth = 2
        doneButton.layer.borderColor = UIColor.briizePink.cgColor
        doneButton.layer.cornerRadius = 10
        doneButton.layer.cornerRadius = 10
        
        submitButton.backgroundColor = .white
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = UIColor.briizePink.cgColor
        submitButton.layer.cornerRadius = 10
        
        notesTextView.layer.cornerRadius = 12

        let tap = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
        dateTimeLabel.addGestureRecognizer(tap)
        dateTimeLabel.isUserInteractionEnabled = true
    }
}

// MARK: - Picker Methods
extension CustomRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        picker.dismiss(animated: true)
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]
            as? UIImage else { return }
        
        switch selectedButton {
        case .left : leftImageView.image = image
        case .right: rightImageView.image = image
        }
    }
    
    private func takePhoto(from imageSource: ImageSource) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        
        switch imageSource {
        case .camera      : imagePicker.sourceType = .camera
        case .photoLibrary: imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func chooseImageSourceAlertFrom(buttonSource: ButtonSource) {
        selectedButton = buttonSource
        
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
