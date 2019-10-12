//
//  ExpertMapListViewController.swift
//  Briize
//
//  Created by Miles Fishman on 10/9/19.
//  Copyright © 2019 Miles Fishman. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ExpertMapListViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var expertView: UIView!
    @IBOutlet weak var expertPhoto: UIImageView!
    @IBOutlet weak var expertFullName: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var viewModel: ExpertMapListViewModel? {
        didSet {
            annotations = viewModel?.experts
                .compactMap({ (user) -> MKPointAnnotation in
                    let point = MKPointAnnotation()
                    point.title = user?.name
                    point.coordinate = CLLocationCoordinate2D(
                        latitude : user?.currentLocation?.latitude ?? 0,
                        longitude: user?.currentLocation?.longitude ?? 0
                    )
                    return point
                }) ?? []
        }
    }
    
    private var annotations: [MKPointAnnotation] = []
    
    private let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = UIColor.white
        
        title = "Select An Expert"
        
        map.delegate = self
        
        let initialLocation = CLLocation(latitude: 34.0407, longitude: -118.2468)
        centerMapOnLocation(location: initialLocation)
        
        map.mapType = .mutedStandard
        map.layer.cornerRadius = 12
        map.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        map.layer.borderWidth = 1.0
        map.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutExpertView()
    }
  
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center            : location.coordinate,
            latitudinalMeters : regionRadius,
            longitudinalMeters: regionRadius
        )
        map.setRegion(coordinateRegion, animated: false)
    }
    
    private func layoutExpertView(from view: MKAnnotationView = MKAnnotationView(), onWillAppear: Bool = true) {
       let expert = !onWillAppear ?
            viewModel?.experts
                .filter({ $0?.name == view.reuseIdentifier })
                .compactMap({ $0 })
                .first :
            viewModel?.experts
                .compactMap({ $0 })
                .first
        
        expertPhoto.downloadedFromAPI(with: expert?.id ?? "")
        expertFullName.text = expert?.name
        priceLabel.text = expert?.price
    }
    
    @IBAction func instagramPressed(_ sender: Any) {
        
    }
    
    @IBAction func twilioMessagePressed(_ sender: Any) {
        
    }
    
    @IBAction func makeRequestPressed(_ sender: Any) {
        
    }
}

extension ExpertMapListViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation,
            let identifier = (annotation.title ?? "")
            else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        annotationView == nil ?
            (annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)) :
            (annotationView?.annotation = annotation)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        layoutExpertView(from: view, onWillAppear: false)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        guard fullyRendered else { return }
        
        mapView.addAnnotations(annotations)
        mapView.selectAnnotation(
            annotations
                .filter({ $0.title == expertFullName.text })
                .first ?? MKPointAnnotation(),
            animated: false
        )
    }
}
