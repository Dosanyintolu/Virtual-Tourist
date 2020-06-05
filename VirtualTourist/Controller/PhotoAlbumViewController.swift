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
    var fetchResultController: NSFetchedResultsController<FlickrImage>!
   
   
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var clearbutton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        photoCollection.delegate = self
        photoCollection.dataSource = self
        imageLabel.isHidden = true
        downloadImageDetailsFromFlickr()
        let space: CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 1.5
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
        downloadImageDetailsFromFlickr()
    }
    
    func setUpFetchedResultsViewController() {
           let fetchRequest: NSFetchRequest<FlickrImage> = FlickrImage.fetchRequest()
           let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
           fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
           
           fetchResultController.delegate = self
           do {
               try fetchResultController.performFetch()
           } catch {
               print(error.localizedDescription)
           }
       }
    
    
    @IBAction func deleteButton(_ sender: Any) {
        
        for image in fetchResultController.fetchedObjects! {
            dataController.viewContext.delete(image)
            try? dataController.viewContext.save()
        }
        photoCollection.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
        let flickr = fetchResultController.object(at: indexPath)
        cell.imageView.image = UIImage(data: flickr.url!)
        
        
        if cell.imageView.image == nil {
            imageLabel.isHidden = false
        }
        return cell
    }
}
