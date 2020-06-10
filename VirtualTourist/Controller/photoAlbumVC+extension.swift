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
                for image in photo {
                    self.photoStore.append(image.url_m)
                }
                self.downloadImage()
            } else {
                print(error?.localizedDescription ?? "Error in the fetch image block")
                print("problem in downloading details.")
            }
        }
    }
    
    func downloadImage() {
        for flickrImageURL in photoStore {
            flickrClient.getImage(imageUrl: flickrImageURL) { (data, error) in
            if error == nil {
                let flickrImage = FlickrImage(context: self.dataController.viewContext)
                self.photoData.append(data!)
                flickrImage.photo = data
                try? self.dataController.viewContext.save()
                print(flickrImage)
            } else {
                print(error?.localizedDescription ?? "Something went wrong downloading an image")
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
