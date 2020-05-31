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
    
    var location: Location!
    var dataController: DataController!
    var fetchResultController: NSFetchedResultsController<Location>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewTapped(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        setUpFetchedResultsViewController()
        getLocationFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultController = nil
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
    
    func getLocationFromCoreData() {
        for location in fetchResultController.fetchedObjects! {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = location.latitude
            annotation.coordinate.longitude = location.longitude
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "toPhotos", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? photoAlbumViewController {
                vc.latitude = location.latitude
                vc.longitude = location.longitude
                vc.dataController = dataController
        }
    }
}

