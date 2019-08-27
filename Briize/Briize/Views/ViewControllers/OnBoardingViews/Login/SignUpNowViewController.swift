//
//  SignUpNowViewController.swift
//  Briize
//
//  Created by Miles Fishman on 8/27/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class SignUpNowViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var certificationImageView: UIImageView!
    @IBOutlet weak var submitNextButton: UIButton!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    let imageViewHeightExpandedHeight = 150.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        navigationItem.titleView = v

        submitNextButton.layer.cornerRadius = 25

        segmentSelected(self)
        setupTextFields()
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
            $0.borderStyle = UITextField.BorderStyle.none
            self.addBottomBorderToTextField(myTextField: $0)

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
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkText]
            )
        })
    }

    private func addBottomBorderToTextField(myTextField: UITextField) {
        let bottomLine   = CALayer()
        bottomLine.frame = CGRect(
            x:0.0,y: myTextField.frame.height - 1,
            width  : self.view.frame.width - 40,
            height : 1.0
        )
        bottomLine.backgroundColor = UIColor.black.cgColor

        myTextField.borderStyle = UITextField.BorderStyle.none
        myTextField.layer.addSublayer(bottomLine)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    

    @IBAction func segmentSelected(_ sender: Any) {
        let height: CGFloat = segmentController.selectedSegmentIndex == 1 ? 150 : 0

        UIView.animate(withDuration: 0.3) {
            self.imageViewHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func submitButtonPressed(_ sender: Any) {

    }
}
