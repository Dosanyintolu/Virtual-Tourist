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
        flickrClient.getImageDetailsFromFlickr(lat: 36.83726811884947, lon: -83.94480415458935) { (photo, error) in
            self.imageLoading(is: true)
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
                self.imageLoading(is: false)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
          return fetchResultController.sections?.count ?? 1
      }
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          let flickr = fetchResultController.fetchedObjects!
          
          if flickr.count == 0 {
              imageLabel.isHidden = false
          }
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
                   try? self.dataController.viewContext.save()
                   self.photoCollection.reloadData()
               }))
               present(alertVC, animated: true, completion: nil)
           }
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
           let image = fetchResultController.object(at: indexPath)
           
        if image.photo?.isEmpty ?? false {
               self.imageLabel.isHidden = false
           } else {
           DispatchQueue.main.async {
               cell.imageView.image = UIImage(data: image.photo!)
               }
            photoCollection.reloadData()
       }
           return cell
       }
}
