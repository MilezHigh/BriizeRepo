//
//  RequestDatePickerViewController.swift
//  Briize
//
//  Created by Admin on 6/29/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit

class RequestDatePickerViewController: UIViewController {
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var dateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = #imageLiteral(resourceName: "singleB-1")
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: v.frame)
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit
        v.addSubview(imageView)
        self.navigationItem.titleView = v
        
        self.showDatePicker()
    }
    
    func showDatePicker(){
        self.dateTextField.becomeFirstResponder()
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(RequestDatePickerViewController.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(RequestDatePickerViewController.cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.dateTextField.inputAccessoryView = toolbar
        self.dateTextField.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
        
        self.dateTextField.text = strDate
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
