//
//  MapViewController+Extension.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 6/10/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation
import MapKit
import UIKit


extension MapViewController {
    
    func getLocationFromCoreData() {
        for location in fetchResultController.fetchedObjects! {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = location.latitude
            annotation.coordinate.longitude = location.longitude
            mapView.addAnnotation(annotation)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           let reuseId = "pin"
           var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

           if pinView == nil {
               pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
               pinView!.animatesDrop = true
               pinView!.pinTintColor = UIColor.red
           }
           else {
               pinView!.annotation = annotation
           }
           return pinView
       }
       
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       var selectedAnnotation: MKPointAnnotation!
       selectedAnnotation = view.annotation as? MKPointAnnotation
       latitude = selectedAnnotation.coordinate.latitude
       longitude = selectedAnnotation.coordinate.longitude
       let savedPins = fetchResultController.fetchedObjects! as [Location]
        location = savedPins.filter({$0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude}).first
       performSegue(withIdentifier: "toPhotos", sender: self)
        
        
        
        
    }
}
