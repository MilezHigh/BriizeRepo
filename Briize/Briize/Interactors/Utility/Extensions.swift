//
//  Extensions.swift
//  Briize
//
//  Created by Admin on 6/2/18.
//  Copyright © 2018 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Parse

public var kExpertTableViewHeight: CGFloat = 189.0
public var kExpertTableCellHeight: CGFloat = 188.0

public var kHeroImage: Int = 0

// MARK: - Protocols
protocol BriizeObject: AnyObject {
    var sessionManager: BriizeManager { get }
}

// MARK: - Extensions
// MARK: * UIView
extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    public func gradientOverlay() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds.applying(CGAffineTransform(scaleX: 3, y: 3))
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.cgColor
        ]
        gradient.locations = [0, 0.4, 0.8]
        
        let baseOverlay = UIView(frame: self.frame)
        baseOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseOverlay.backgroundColor = .black
        baseOverlay.layer.mask = gradient
        
        if self.tag != 1 {
            self.tag = 1
            self.addSubview(baseOverlay)
        }
    }
    
    public func blur(_ rect: CGRect){
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = rect
        self.addSubview(blurView)
    }
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: * UIImageView
extension UIImageView {
    
    func darkOverlay(){
        guard let screenWidth = UIApplication.shared.keyWindow?.rootViewController?.view.bounds.width else {return}
        let overlayview = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: self.frame.height))
        overlayview.backgroundColor = .black
        overlayview.alpha = 0.4
        overlayview.isUserInteractionEnabled = false
        self.insertSubview(overlayview, at: 0)
    }
    
    
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill, setProfileImage: Bool) {
        self.image = nil
        self.clipsToBounds = true
        self.contentMode = mode
        self.alpha = 0
        
        let act = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        act.type = .ballGridPulse
        act.color = .briizePink
        self.addSubview(act)
        act.center = self.center
        act.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let this = self,
                let data = data,
                error == nil,
                let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self?.alpha = 0
                        UIView.animate(withDuration: 0.25, animations: {
                            act.removeFromSuperview()
                            self?.clipsToBounds = false
                            self?.layer.borderWidth = 1.0
                            self?.layer.borderColor = UIColor.lightGray.cgColor
                            self?.image = nil
                            self?.alpha = 1
                        })
                    } ; return
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    act.removeFromSuperview()
                    this.image = image
                    this.layer.cornerRadius = this.frame.size.width / 2
                    this.alpha = 1
                })
            }
        }
        .resume() ; return
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill, setProfileImage: Bool) {
        guard let url = URL(string: link) else { return }
        self.downloadedFrom(url: url, contentMode: mode, setProfileImage: setProfileImage)
    }
    
    func downloadedFromAPI(with userID: String, isClient: Bool = true) {
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: userID)
        query.getFirstObjectInBackground { [weak self] (object, error) in
            switch error != nil {
            case true:
                print("Error on async image download from API - \(error!.localizedDescription)")
                
            case false:
                if let object = object {
                    guard let file = object["profilePhoto"] as? PFFileObject,
                        let url = file.url else { return }
                    self?.downloadedFrom(link: url, setProfileImage: isClient)
                }
            }
        }
    }
}

extension UISegmentedControl {
    
    func removeBorder(){
        let backgroundImage = UIImage
            .getColoredRectImageWith(color: UIColor.white.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
        let dividerImage = UIImage.getColoredRectImageWith(
            color  : UIColor.white.cgColor,
            andSize: CGSize(width: 1.0, height: self.bounds.size.height)
        )
        self.setDividerImage(
            dividerImage,
            forLeftSegmentState: .selected,
            rightSegmentState  : .normal,
            barMetrics         : .default
        )
        
        let font = UIFont.systemFont(ofSize: 17)
        self.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: font
            ],
                                    for: .normal
        )
        self.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(
                red  : 214/255,
                green: 165/255,
                blue : 141/255,
                alpha: 1.0
            ),
            NSAttributedString.Key.font: font
            ],
                                    for: .selected
        )
    }
    
    func addUnderlineForSelectedSegment() {
        removeBorder()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height
        let underlineFrame = CGRect(
            x     : underlineXPosition,
            y     : underLineYPosition,
            width : underlineWidth,
            height: underlineHeight
        )
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor(red: 214/255, green: 165/255, blue: 141/255, alpha: 1.0)
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func changeUnderlinePosition() {
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.2, animations: { underline.frame.origin.x = underlineFinalXPosition })
    }
}

extension UIImage {
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(
            x     : 0.0,
            y     : 0.0,
            width : size.width,
            height: size.height
        )
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}

extension UICollectionViewCell: BriizeObject {
    var sessionManager: BriizeManager {
        get { return BriizeManager.shared }
    }
}

extension UIViewController: BriizeObject {
    
    /// Briize Manager Methods
    
    var sessionManager: BriizeManager {
        get { return BriizeManager.shared }
    }
    
    var sessionUserIsExpert: Bool {
        return sessionManager.user.model.value?.isExpert == true
    }
    
    /// Navigation Bar Methods
    
    @objc private func dismissController() {
        dismiss(animated: true)
    }
    
    public func addDismissButton() {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(dismissController)
        )
        closeButton.tintColor = .briizePink
        navigationItem.leftBarButtonItems = [closeButton]
    }
}

extension UIColor {
    
    static var briizePink: UIColor {
        return UIColor(red: 223.0/255.0, green: 163.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    }
}

extension UITextField {
    public func addBottomBorderToTextField(color: UIColor = .black) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(
            x      : 0.0,
            y      : frame.height - 1,
            width  : UIScreen.main.bounds.width - 40,
            height : 1.0
        )
        bottomLine.backgroundColor = color.cgColor
        borderStyle = UITextField.BorderStyle.none
        layer.addSublayer(bottomLine)
    }
}


extension Data {
    func pfFileObject() -> PFFileObject? {
        return PFFileObject(data: self)
    }
}

extension DateFormatter {
    static func prettyDate(from string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
    }
}

extension Double {
    
    static var fifteenMilesInMeters: Double {
        get {
            return 1609.344 * 15
        }
    }
}

class BriizeUtility {
    
    static func convertPFObjectToMultipleSectionModel(_ object: PFObject) -> SectionItem? {
        guard
            let objId = object.objectId,
            let name = object["fullName"] as? String,
            let imageFile = object["profilePhoto"] as? PFFileObject,
            let rating = object["rating"] as? Double,
            let servicesOffered = object["servicesOffered"] as? NSDictionary,
            let data = servicesOffered["data"] as? [NSDictionary]
            // Complete expert model for expert result page
            else { return nil }
        
        let price: Int = data
            .map ({ (dic) -> Int in
                guard let price = dic["cost"] as? Int else { return 0 }
                return price
            })
            .reduce(0, +)
        
        let location: PFGeoPoint? = object["currentLocation"] as? PFGeoPoint
        
        let userModel = UserModel.init(
            name: name,
            price: "$\(price.description)",
            state: "",
            phone: "",
            rating: rating,
            email: "",
            id: objId,
            distance: "",
            isExpert: true,
            urlString: imageFile,
            currentLocation: location
        )
        
        return SectionItem.IndividualExpertItem(model: userModel)
    }
}
