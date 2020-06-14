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
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var clearbutton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        collectionViewFlowLayout()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        setUpFetchedResultsViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadImageDetailsFromFlickr()
        imageLabel.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
    }
    
    func setUpMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
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
            for image in imagesInFlickr {
                dataController.viewContext.delete(image)
                downloadImageDetailsFromFlickr()
                try? dataController.viewContext.save()
                photoCollection.reloadData()
            }
        downloadImageDetailsFromFlickr()
        }
    }
    
    @IBAction func deleteAllImages(_ sender: Any) {
        for images in fetchResultController.fetchedObjects! {
            dataController.viewContext.delete(images)
            try? dataController.viewContext.save()
            photoCollection.reloadData()
        }
    }
    
    func imageLoading(is downloading: Bool) {
           newCollectionButton.isEnabled = !downloading
       }
       
//    func checkForImages() {
//       let flickrImages = fetchResultController.fetchedObjects!
//           if flickrImages.count == 0 {
//               self.downloadImageDetailsFromFlickr()
//           }
//       }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           switch type {
           case .delete: photoCollection.deleteItems(at: [indexPath!])
           case .insert: photoCollection.insertItems(at: [indexPath!])
           default:
               break
           }
       }
}
