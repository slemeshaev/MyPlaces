//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Станислав Лемешаев on 21.10.2019.
//  Copyright © 2019 Станислав Лемешаев. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place: Place!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceMark()
    }

    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupPlaceMark() {
        
        guard let location = place.location else { return }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
