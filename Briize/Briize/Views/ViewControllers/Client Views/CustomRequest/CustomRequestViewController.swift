//
//  CustomRequestViewController.swift
//  Briize
//
//  Created by Miles Fishman on 3/21/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CustomRequestViewController: UIViewController {
    
    @IBOutlet weak var leftPhotoButton: UIButton!
    @IBOutlet weak var rightPhotoButton: UIButton!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    private enum ButtonSource {
        case left
        case right
    }
    
    private enum ImageSource {
        case camera
        case photoLibrary
    }
    
    private var imagePicker: UIImagePickerController!
    private var selectedButton: ButtonSource = .left
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindSlider()
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        self.chooseImageSourceAlertFrom(buttonSource: .left)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        self.chooseImageSourceAlertFrom(buttonSource: .right)
    }
    
}

extension CustomRequestViewController {
    
    private func bindSlider() {
        self.priceSlider.minimumValue = 0
        self.priceSlider.maximumValue = 1000
        self.priceSlider.value = 125
        self.priceSlider.rx.value
            .asDriver()
            .drive(
                onNext: { [weak self] (value) in
                    let roundedValue = round(value / 5) * 5
                    self?.priceLabel.text = "$" + Int(roundedValue).description
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setup() {
        
    }
    
}

extension CustomRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true)
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
        switch self.selectedButton {
        case .left:
            self.leftImageView.image = image
            
        case .right:
            self.rightImageView.image = image
        }
    }
    
    private func takePhoto(from imageSource: ImageSource) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        
        switch imageSource {
        case .camera:
            imagePicker.sourceType = .camera
            
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func chooseImageSourceAlertFrom(buttonSource: ButtonSource) {
        self.selectedButton = buttonSource
        
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
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
