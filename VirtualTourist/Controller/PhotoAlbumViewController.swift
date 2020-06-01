//
//  photoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class photoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
   
    var location: Location!
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<Location>!
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        photoCollection.delegate = self
        photoCollection.dataSource = self
        imageLabel.isHidden = true
        downloadImagesFromFlickr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: 32.8297529087073 , longitude: -98.30174486714975)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        annotation.coordinate = coordinate
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        setUpFetchedResultsViewController()
        
    }
    
    func downloadImagesFromFlickr() {
        flickrClient.getImageFromFlickr(lat: 32.8297529087073, lon: -98.30174486714975) { (photo, error) in
            if error == nil {
                let flickr = FlickrImage(context: self.dataController.viewContext)
                flickr.id = photo?.id
                flickr.farm = photo?.farm
                flickr.isFamily = photo?.isFamily
                flickr.isPublic = photo?.isPublic
                flickr.server = photo?.server
                flickr.owner = photo?.owner
                flickr.secret = photo?.secret
                flickr.title = photo?.title
                flickr.isFriend = photo?.isFriend
                print(flickr)
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? "Error in the fetch image block")
            }
        }
    }
    
    
    func setUpFetchedResultsViewController() {
           let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
           let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
           fetchRequest.sortDescriptors = [sortDescriptor]
           fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
           
           fetchResultController.delegate = self
           do {
               try fetchResultController.performFetch()
           } catch {
               print(error.localizedDescription)
           }
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
        
        guard let imagee = UIImage(data: location.flickrImages!) else { return cell }
        cell.imageView.image = imagee
        
        do {
        try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        if collectionView.visibleCells.count < 1 {
            imageLabel.isHidden = false
        }
        return cell
       }
    
}

extension photoAlbumViewController {
    
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
