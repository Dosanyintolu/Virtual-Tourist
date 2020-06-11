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
           performSegue(withIdentifier: "toPhotos", sender: nil)
        location.append(mapView.selectedAnnotations[0])
        }
    
}
