//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Reem on 5/23/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mainActiviyIndicator: UIActivityIndicatorView!
    
    var indeciesToInsert: [IndexPath]!
    var indeciesToDelete: [IndexPath]!
    var indeciesToUpdate: [IndexPath]!
   
    
    var pin: Pin!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    let annotation = MKPointAnnotation()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        cellSize()
        DispatchQueue.main.async {
            self.statusLabel.text = ""
        }
        
        fetchPhotos()
        addPinToView(pin)
        if pin.photos?.count == 0 {
            DispatchQueue.main.async {
               
                self.mainActiviyIndicator.startAnimating()
            }
            downloadImages(longitude: pin.longitude, latitude: pin.latitude)
        }
    }
    
    func fetchPhotos() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    
    func cellSize(){
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    private func addPinToView(_ pin: Pin) {
        
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
    }
    
    func downloadImages(longitude: Double, latitude: Double)
    {
        let request = APIRequest(method: "flickr.photos.search", galleryID: "", extras: [], format: "jsonfm", safeSearch: "1", lat: latitude, lon: longitude, photosPerPage: 10, accuracy: 11, page: 1)
        
        var responseArray = [APIResponse]()
        
        FlickrClient.getPhotos(body: request) { (response, error) in
            
            if let response = response {
                
                if (response.photos?.photo?.count)! > 0 {
                    for resultPhoto in (response.photos?.photo)! {
                        
                        if  resultPhoto.url != "" {
                            
                            responseArray.append(resultPhoto)
                        }
                        
                    }
                    self.addImageToContext(photos: responseArray, pin: self.pin)
                }
                else {
                    
                    self.statusLabel.text = "No Images found in this location"
                    
                }
                
            }
            else {
                Utility.showAlert(message: (error?.localizedDescription)!, controller: self)
            }
        }
        
    }
    
    
    func addImageToContext(photos: [APIResponse], pin: Pin)
    {
     
        
        for photo in photos {
            
            let photoToStore = Photo(context: self.dataController.context)
            
            if photo.url != nil {
                photoToStore.pin = pin
                photoToStore.url = photo.url
                photoToStore.photoData = try? Data(contentsOf: URL(string: photo.url!)!)
              
            }

            try? self.dataController.context.save()
            
        }
        
    }
    
    func getImage(_ photo: Photo, for cell: PhotoCell, collection: UICollectionView, index: IndexPath) {
        
        DispatchQueue.global(qos: .background).async {
            var data = Data()
            data = Data(referencing: photo.photoData! as NSData)
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data)
                cell.activityIndicator.stopAnimating()
                self.mainActiviyIndicator.stopAnimating()
            }
        }
        
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        for images in fetchedResultsController.fetchedObjects! {
            dataController.context.delete(images)
        }
        try? dataController.context.save()
        downloadImages(longitude: pin.longitude, latitude: pin.latitude)
    }
    
}





extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let info = self.fetchedResultsController.sections?[section]
        
        return info?.numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        self.getImage(photo, for: cell, collection: collectionView, index: indexPath)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.context.delete(photoToDelete)
        try? dataController.context.save()
    }
    
}


extension CollectionViewController: MKMapViewDelegate {
    
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
    
}


extension CollectionViewController:NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.indeciesToInsert = [IndexPath]()
        self.indeciesToDelete = [IndexPath]()
        self.indeciesToUpdate = [IndexPath]()
        
    }
    
    
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            indeciesToInsert.append(newIndexPath!)
            break
        case .delete:
            indeciesToDelete.append(indexPath!)
            break
        case .update:
            indeciesToUpdate.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.indeciesToInsert {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.indeciesToDelete {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.indeciesToUpdate {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        })
    }
}



