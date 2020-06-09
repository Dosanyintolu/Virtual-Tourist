//
//  photoAlbumVC+extension.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 6/3/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension photoAlbumViewController {
    
    func downloadImageDetailsFromFlickr() {
        flickrClient.getImageDetailsFromFlickr(lat: 32.8297529087073, lon: -98.30174486714975) { (photo, error) in
            if error == nil {
                for i in photo {
                    let flickr = FlickrImage(context: self.dataController.viewContext)
                    
                    flickr.id = i.id
                    flickr.url = i.url_m
                    flickr.owner = i.owner
                    flickr.secret = i.secret
                    flickr.server = i.server
                    flickr.farm = Int16(Int(i.farm))
                    try? self.dataController.viewContext.save()
                    }
                self.downloadImage()
            } else {
                print(error?.localizedDescription ?? "Error in the fetch image block")
                print("problem in downloading details.")
            }
        }
    }
    
    func downloadImage() {
        let flickr = FlickrImage(context: self.dataController.viewContext)
        flickrClient.getImage(imageUrl: flickr.url!) { (data, error) in
            if error == nil {
                flickr.photo = data
                do {
                    print(flickr.photo!)
                    try self.dataController.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let annotation = MKPointAnnotation()
          let reuseId = "pin"
          var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

          if pinView == nil {
              pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
              pinView!.animatesDrop = true
              pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
              pinView!.pinTintColor = UIColor.red
          }
          else {
              pinView!.annotation = annotation
          }
          return pinView
      }
    
}
