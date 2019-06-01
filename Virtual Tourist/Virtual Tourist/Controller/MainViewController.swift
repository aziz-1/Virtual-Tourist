//
//  MainViewController.swift
//  Virtual Tourist
//
//  Created by Reem on 5/23/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class MainViewController: UIViewController {
 
    @IBOutlet weak var mapView: MKMapView!
    var annotation = MKPointAnnotation()
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = false
        fetchPins()
        if let pins = fetchedResultsController.fetchedObjects {
        addPinsToView(pins: pins)
        }
       
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    

    @IBAction func newPin(_ sender: UILongPressGestureRecognizer) {
        
        let touchedPlace = sender.location(in: mapView)
        let coordinates = mapView.convert(touchedPlace, toCoordinateFrom: mapView)
        if sender.state == .ended {
        annotation.coordinate = coordinates
   
            let pin = Pin(context: dataController.context)
            pin.longitude = Double(annotation.coordinate.longitude)
            pin.latitude = Double(annotation.coordinate.latitude)

            
            try? dataController.context.save()
            addPinsToView(pins: [pin])
            performSegue(withIdentifier: "collectionSegue", sender: pin)
            
        }
    }
    
    
    func fetchPins() {
  
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
       
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func checkPin(pin: CLLocationCoordinate2D) -> Pin? {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pin.latitude, pin.longitude])
        fetchRequest.predicate = predicate
        var pin: Pin?
        do {
         try pin = dataController.context.fetch(fetchRequest).first
        } catch {
           fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        return pin
    }
    

    
     func addPinsToView(pins: [Pin]) {

        for pin in pins {
            let newAnnotation = MKPointAnnotation()
            let latitude = Double(pin.latitude)
            let longitude = Double(pin.longitude)
            newAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            mapView.addAnnotation(newAnnotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CollectionViewController {
            guard let pin = sender as? Pin else {
                return
            }
            let vc = segue.destination as! CollectionViewController
            vc.pin = pin
            vc.dataController = dataController
        }
    }
    
}

extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            Utility.showAlert(message: "Not Found.", controller: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
    
        mapView.deselectAnnotation(annotation, animated: true)
       
        if let pin = checkPin(pin: annotation.coordinate) {
   
        performSegue(withIdentifier: "collectionSegue", sender: pin)
        }
        else {
           Utility.showAlert(message: "Not Found", controller: self)
        }


    }
    
}

extension MainViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
             mapView.addAnnotation(annotation)
            break
        default:
            break
        }
    }
    
    
}

