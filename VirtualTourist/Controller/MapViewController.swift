//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var clearButton: UIButton!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<Location>!
    let locationDefaults =  UserDefaults.standard
    var zoom = MKCoordinateSpan()
    var location: Location!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewTapped(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        setUpFetchedResultsViewController()
        getLocationFromCoreData()
        mapViewInterfaceStore()
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapViewInterfaceSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
    }
    
    func mapViewInterfaceStore() {
        locationDefaults.set(mapView.centerCoordinate.latitude, forKey: "latitude")
        locationDefaults.set(mapView.centerCoordinate.longitude, forKey: "longitude")
        locationDefaults.set(10.0, forKey: "latDelta")
        locationDefaults.set(10.0, forKey: "lonDelta")
    }
    
    func mapViewInterfaceSetUp() {
        let coordinate = CLLocationCoordinate2D(latitude:locationDefaults.double(forKey: "latitude"), longitude: locationDefaults.double(forKey: "longitude"))
        let span = MKCoordinateSpan(latitudeDelta: locationDefaults.double(forKey: "latDelta"), longitudeDelta: locationDefaults.double(forKey: "lonDelta"))
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapViewInterfaceStore()
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
         mapViewInterfaceStore()
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
    
   @objc func mapViewTapped(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
        let locationStore = Location(context: dataController.viewContext)
        let annotation = MKPointAnnotation()
        let location =  gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        
        annotation.coordinate = coordinate
        locationStore.longitude = annotation.coordinate.longitude
        locationStore.latitude = annotation.coordinate.latitude
        mapView.addAnnotation(annotation)
        do {
            try dataController.viewContext.save()
        }catch {
            print(error)
        }
        try? fetchResultController.performFetch()
    }
}
    @IBAction func clearAnnotations(_ sender: Any) {
        
        let alert = UIAlertController(title: "Delete Pins", message: "Confirm deleting all Pins", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete all", style: .destructive, handler: { (_) in
            
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
            for location in self.fetchResultController.fetchedObjects! {
                self.dataController.viewContext.delete(location)
                try? self.dataController.viewContext.save()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? photoAlbumViewController {
            vc.dataController = dataController
            vc.longitude = longitude
            vc.latitude = latitude
            vc.location = location
        }
    }
}

