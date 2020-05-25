//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var clearButton: UIButton!
    
    var lat: Double = 0.0
    var lon: Double = 0.0
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(triggeredAction(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func triggeredAction(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        lat = annotation.coordinate.latitude
        lon = annotation.coordinate.longitude
        print("The location is lat:\(lat) & lon:\(lon)")
    }
    
    @IBAction func clearAnnotations(_ sender: Any) {
        mapView.removeAnnotation(annotation)
    }
}

