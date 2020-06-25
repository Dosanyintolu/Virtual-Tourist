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
    
    func downloadImageDetailsFromFlickr(completion: @escaping (Bool, Error?) -> Void) {
        self.imageLoading(is: true)
        flickrClient.getImageDetailsFromFlickr(lat: latitude, lon: longitude) { (photo, error) in
            if error == nil {
                self.photoStore = []
                for image in photo {
                    if image.url_m.count == 0 {
                        self.imageLabel.isHidden = false
                        self.imageLoading(is: false)
                        completion(false, nil)
                    } else {
                      self.photoStore.append(image.url_m)
                        print(self.photoStore)
                        completion(true, nil)
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Error in the fetch image block")
                print("problem in downloading details.")
                completion(false, error)
            }
        }
    }
    
    func downloadImage(completion: @escaping(Bool, Error?) -> Void ) {
        let flickrImage = FlickrImage(context: self.dataController.viewContext)
        
        for flickr in photoStore {
            self.photoUrl = ""
            self.photoUrl = flickr
        }
            flickrClient.getImage(imageUrl: photoUrl ?? "") { (data, error) in
                if error == nil {
                self.imageLoading(is: false)
                    flickrImage.photo = data
                    flickrImage.url = self.photoUrl
                    flickrImage.locations = self.location
                    flickrImage.locations?.latitude = self.latitude
                    flickrImage.locations?.longitude = self.longitude
                }
                else {
                    print(error?.localizedDescription ?? "Something went wrong downloading an image")
                    }
            do {
                 try self.dataController.viewContext.save()
                 self.photoStore.removeAll()
                 completion(true, nil)
                } catch {
                 print("Error saving into Core Data")
                 completion(false, error)
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
                DispatchQueue.main.async {
                    self.photoCollection.deleteItems(at: [indexPath])
                    self.photoCollection.reloadData()
                }
               }))
               present(alertVC, animated: true, completion: nil)
           }
       }
    
  
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
        let image = fetchResultController.object(at: indexPath)
                if let cellImage = image.photo {
                      DispatchQueue.main.async {
                           cell.imageView.image = UIImage(data: cellImage)
                      }
        }
        return cell
    }
}


