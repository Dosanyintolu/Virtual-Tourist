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
   
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<FlickrImage>!
    var photoStore: [String] = []
    var photoData: [Data] = []
    var latitude: Double = 0
    var longitude: Double = 0
    var location: Location!
    var flickr: [FlickrImage] = []
    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var newImageButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        collectionViewFlowLayout()
        imageLabel.isHidden = true
        newImageButton.addTarget(self, action: #selector(deleteItems), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        setUpFetchedResultsViewController()
        downloadImageDetailsFromFlickr()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
        photoStore = []
        photoData = []
        latitude = 0
        longitude = 0
    }
    
    func setUpMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        print(longitude, latitude)
        let coordinate = CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        annotation.coordinate = coordinate
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func collectionViewFlowLayout() {
        let space: CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 1.5
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func setUpFetchedResultsViewController() {
           let fetchRequest: NSFetchRequest<FlickrImage> = FlickrImage.fetchRequest()
           let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
        let predicate = NSPredicate(format: "locations == %@", location)
        fetchRequest.predicate = predicate
           fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
           fetchResultController.delegate = self
           do {
               try fetchResultController.performFetch()
           } catch {
               print(error.localizedDescription)
           }
        checkForImages()
    }
    
    @IBAction func fetchNewImages(_ sender: Any) {
    
    }
    
    @objc func deleteItems() {
        let imagesInFlickr = fetchResultController.fetchedObjects!
        let indexPath = IndexPath(row: 0, section: 0)
           for image in imagesInFlickr {
            dataController.viewContext.delete(image)
            photoCollection.deleteItems(at: [indexPath])
            try? dataController.viewContext.save()
           }
           downloadImageDetailsFromFlickr()
           self.photoCollection.reloadData()
    }
    
    
    func imageLoading(is downloading: Bool) {
           newCollectionButton.isEnabled = !downloading
       }
    
    func checkForImages() {
     if fetchResultController.fetchedObjects!.count == 0 {
        downloadImageDetailsFromFlickr()
        try? fetchResultController.performFetch()
        photoCollection.reloadData()
        }
    }
}
