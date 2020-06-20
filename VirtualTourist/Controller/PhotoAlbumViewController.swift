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
    var flickr: FlickrImage!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var clearbutton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        collectionViewFlowLayout()
        setUpFetchedResultsViewController()
        imageLabel.isHidden = true
        downloadImageDetailsFromFlickr(completion: handleResponse(success:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        setUpFetchedResultsViewController()
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
    }
    
    func handleResponse(success: Bool, error: Error?) {
        if success {
            self.downloadImage()
        } else {
            print(error!)
        }
    }
    
    func setUpMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
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
           let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
//        let predicate = NSPredicate(format: "latitude == %@", latitude)
//           fetchRequest.predicate = predicate
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
            for image in imagesInFlickr {
                dataController.viewContext.delete(image)
                try? dataController.viewContext.save()
            }
            downloadImageDetailsFromFlickr(completion: handleResponse(success:error:))
            try? fetchResultController.performFetch()
            photoCollection.reloadData()    
    }
    
    func imageLoading(is downloading: Bool) {
           newCollectionButton.isEnabled = !downloading
       }
}
