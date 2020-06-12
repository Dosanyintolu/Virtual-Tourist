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
   
    var location: [Location]!
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<FlickrImage>!
    var photoStore: [String] = []
    var photoData: [Data] = []
    var flickr: [FlickrImage] = []
    var locationValue: Location!
    
    @IBOutlet weak var newCollectionButton: UIButton!
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
        let space: CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 1.5
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for location in location {
            self.locationValue = location
        let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        annotation.coordinate = coordinate
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        }
        setUpFetchedResultsViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.downloadImageDetailsFromFlickr()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchResultController = nil
    }
    
    func setUpFetchedResultsViewController() {
           let fetchRequest: NSFetchRequest<FlickrImage> = FlickrImage.fetchRequest()
           let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
           fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
           
           fetchResultController.delegate = self
           do {
               try fetchResultController.performFetch()
           } catch {
               print(error.localizedDescription)
           }
       }
    
    @IBAction func fetchNewImages(_ sender: Any) {
        let imagesInFlickr = fetchResultController.fetchedObjects!
        if imagesInFlickr.count == 0 {
            downloadImageDetailsFromFlickr()
            try? dataController.viewContext.save()
            photoCollection.reloadData()
        } else {
            for image in imagesInFlickr {
                dataController.viewContext.delete(image)
                downloadImageDetailsFromFlickr()
                try? dataController.viewContext.save()
                photoCollection.reloadData()
            }
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
        
        if image.photo == nil {
            self.imageLabel.isHidden = false
        } else {
        DispatchQueue.main.async {
            cell.imageView.image = UIImage(data: image.photo!)
            }
    }
        return cell
    }
}
