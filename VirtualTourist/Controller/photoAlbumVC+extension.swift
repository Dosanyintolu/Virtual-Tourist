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

extension photoAlbumViewController  {
    
    func downloadImageDetailsFromFlickr() {
        self.imageLoading(is: true)
        flickrClient.getImageDetailsFromFlickr(lat: latitude, lon: longitude) { (photo, error) in
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
        for flickr in photoStore {
            flickrClient.getImage(imageUrl: flickr) { (data, error) in
                if error == nil {
                self.imageLoading(is: false)
                let flickrImage = FlickrImage(context: self.dataController.viewContext)
                flickrImage.photo = data
                flickrImage.url = flickr
                flickrImage.locations = self.location
                flickrImage.locations?.latitude = self.latitude
                flickrImage.locations?.longitude = self.longitude
                    do {
                        try self.dataController.viewContext.save()
                        try self.fetchResultController.performFetch()
                        self.photoCollection.reloadData()
                       } catch {
                        print("Error saving into Core Data")
                       }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultController.sections?.count ?? 1
      }
      
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         
        return fetchResultController.sections?[section].numberOfObjects ?? 0
      }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
           
           if cell.isSelected {
               let alertVC = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
               alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                   let image = self.fetchResultController.object(at: indexPath)
                   self.dataController.viewContext.delete(image)
                do {
                   try self.dataController.viewContext.save()
                    try self.fetchResultController.performFetch()
                } catch {
                    print(error.localizedDescription)
                }
                     self.photoCollection.deleteItems(at: [indexPath])
                     self.photoCollection.reloadData()
               }))
               present(alertVC, animated: true, completion: nil)
           }
       }
    
  
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
        try? fetchResultController.performFetch()
            let image = fetchResultController.object(at: indexPath)
        
        if image.photo == nil {
            imageLabel.isEnabled = true
        } else  {
                  if let cellImage = image.photo {
                      DispatchQueue.main.async {
                           cell.imageView.image = UIImage(data: cellImage)
                      }
              }
        }
        return cell
    }
}


