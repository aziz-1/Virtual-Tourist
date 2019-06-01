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
    var fetchedPinFromContext:NSFetchedResultsController<Pin>!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let dummyPin = Pin()
        dummyPin.latitude = 0.0
        dummyPin.longitude = 0.0
        dataController.context.insert(dummyPin)
        try? dataController.context.save()
        fetchPins()
        addPinsToView()
  
    }
    

    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    

    @IBAction func newPin(_ sender: UILongPressGestureRecognizer) {
        let touchedPlace = sender.location(in: mapView)
        let coordinates = mapView.convert(touchedPlace, toCoordinateFrom: mapView)
        
        annotation.coordinate = coordinates
      
        addPinToContext(newPin: annotation)
    }
    
    func addPinToContext(newPin: MKPointAnnotation)
    {
        let pin = Pin(context: dataController.context)
        pin.longitude = newPin.coordinate.longitude
        pin.latitude = newPin.coordinate.latitude
        try? dataController.context.save()
    }
    
    func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CollectionViewController {
            guard let pin = sender as? Pin else {
                return
            }
            let vc = segue.destination as! CollectionViewController
            vc.pin = pin
        }
    }
    
    fileprivate func addPinsToView() {
        let pins = fetchedResultsController.fetchedObjects
        mapView.removeAnnotations(mapView.annotations)
        
        for pin in pins! {
            addPinToContext(newPin: setupPins(pin: pin))
        }
    }
    
    func setupPins(pin: Pin) -> MKPointAnnotation
    {
        let pinHolder = MKPointAnnotation()
        pinHolder.coordinate.longitude = pin.longitude
        pinHolder.coordinate.latitude = pin.latitude
        return pinHolder
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

        
        let pin = Pin(context: dataController.context)
        pin.longitude = annotation.coordinate.longitude
        pin.latitude = annotation.coordinate.latitude
        performSegue(withIdentifier: "collectionSegue", sender: pin)
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       addPinsToView()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         addPinsToView()
    }
    
}

