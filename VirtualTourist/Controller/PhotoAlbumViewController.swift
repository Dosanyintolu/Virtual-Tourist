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
    var latitude: Double = 0
    var longitude: Double = 0
    var location: Location!
    var photoUrl:String?
    
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
        newImageButton.addTarget(self, action: #selector(fetchNewItems), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapView()
        setUpFetchedResultsViewController(completion: handleFetchedResultController(success:error:))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
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
    
    func setUpFetchedResultsViewController(completion: @escaping (Bool, Error?) -> Void) {
           let fetchRequest: NSFetchRequest<FlickrImage> = FlickrImage.fetchRequest()
           let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
        let predicate = NSPredicate(format: "locations == %@", location)
        fetchRequest.predicate = predicate
           fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
           fetchResultController.delegate = self
           do {
               try fetchResultController.performFetch()
                completion(true, nil)
           } catch {
               print(error.localizedDescription)
                completion(false, error)
           }
    }
    
    @objc func fetchNewItems() {
        fetchFunc(completion: handleFetchFunc(success:error:))
    }
    
    
    func imageLoading(is downloading: Bool) {
           newCollectionButton.isEnabled = !downloading
       }
    
    func checkForImages() {
       if fetchResultController.fetchedObjects!.count == 0 {
                downloadImageDetailsFromFlickr(completion: handleDownload(success:error:))
            }
        }
    
    func fetchFunc(completion: @escaping (Bool, Error?) -> Void) {
        let imagesInFlickr = fetchResultController.fetchedObjects!
        let indexPath = IndexPath(row: 0, section: 0)
           for image in imagesInFlickr {
            dataController.viewContext.delete(image)
            self.photoCollection.deleteItems(at: [indexPath])
        }
        try? dataController.viewContext.save()
        completion(true, nil)
    }
    
    func handleFetchFunc(success: Bool, error: Error?) {
        if success {
            downloadImageDetailsFromFlickr(completion: handleDownload(success:error:))
            try? self.dataController.viewContext.save()
            DispatchQueue.main.async {
                self.photoCollection.reloadData()
            }
            
        } else {
                print(error?.localizedDescription ?? "Problem in fetching")
            }
        }
    
    func handleFetchedResultController(success:Bool, error: Error?) {
        if success{
            self.checkForImages()
        } else {
            print(error?.localizedDescription ?? "")
        }
    }

    func handleDownload(success:Bool, error: Error?) {
        if success {
            downloadImage(completion: handleDownloadedImages(success:error:))
        } else {
            print(error?.localizedDescription ?? "Error in handling downloaded details")
        }
    }
    
    func handleDownloadedImages(success: Bool, error: Error?) {
        if success {
            try? self.fetchResultController.performFetch()
            DispatchQueue.main.async {
            self.photoCollection.reloadData()
            }
        } else {
            print(error?.localizedDescription ?? "Error in handling downloaded Images")
        }
    }
}
