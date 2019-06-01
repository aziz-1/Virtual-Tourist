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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var pin: Pin!
    
    static var pinStatusDictionary = [Pin:Int]()
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Image>!
    
    let annotation = MKPointAnnotation()
    
    func fetchPins() {
        let fetchRequest:NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        cellSize()
        statusLabel.text = ""
        addPinToView(pin)
        fetchPins()
        if let _ = fetchedResultsController.fetchedObjects {
        downloadImages(longitude: pin.longitude, latitude: pin.latitude)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellSize()
        statusLabel.text = ""
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
    }
    
    func downloadImages(longitude: Double, latitude: Double)
    {
        let request = APIRequest(method: "flickr.photos.search", galleryID: "", extras: [], format: "json", safeSearch: "1", lat: latitude, lon: longitude, photosPerPage: 10, accuracy: 11, page: 1)
        
        var loadedImages = [UIImage]()
        
        FlickrClient.getPhotos(body: request) { (response, error) in
            if let response = response?.photos?.photo {
                if response.count > 0 {
                for photo in response {
                    let url = URL(string: photo.url!)
                    let data = try? Data(contentsOf: url!)
                    self.addImageToContext(newImage: data!)
                    loadedImages.append(UIImage(data: data!)!)
                }
                
            }
                else {
                    DispatchQueue.main.async {
                         self.statusLabel.text = "No Images found in this location"
                    }
                }
            }
            else {
                Utility.showAlert(message: (error?.localizedDescription)!, controller: self)
            }
        }
        
     
    }
    
    
    func addImageToContext(newImage: Data)
    {
        DispatchQueue.main.async {
            let image = Image(context: self.dataController.context)
            image.picture = newImage
            try? self.dataController.context.save()
        }
        
    }
    
    private func loadImages(currentCell: PhotoCell, image: Image, collectionView: UICollectionView, index: IndexPath) {
        if let downloadedImage = image.picture {
            currentCell.activityIndicator.stopAnimating()
            currentCell.imageView.image = UIImage(data: Data(referencing: downloadedImage as NSData))
      
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
       return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photoCell = fetchedResultsController.object(at: indexPath)
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as! PhotoCell
    
        cell.activityIndicator.startAnimating()
        //add addtional network request
        if let photo = photoCell.picture {
            cell.imageView.image = UIImage(data: photo)
        }
        
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.context.delete(photoToDelete)
        try? dataController.context.save()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoToShow = fetchedResultsController.object(at: indexPath)
        let convertedCell = cell as! PhotoCell

        loadImages(currentCell: convertedCell, image: photoToShow, collectionView: collectionView, index: indexPath)
    }
    
    

}

extension CollectionViewController: MKMapViewDelegate {
    
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
         var indexPathArray = [IndexPath]()
        indexPathArray.append(indexPath!)
        
       
        switch type {
           
        case .insert:
            collectionView.performBatchUpdates({() -> Void in
                
                for i in indexPathArray {
                    self.collectionView.insertItems(at: [i])
                }})
            break
        case .delete:
             collectionView.performBatchUpdates({() -> Void in
                  for i in indexPathArray {
                    collectionView.deleteItems(at: [i])
                }})
            break
        case .update:
            collectionView.performBatchUpdates({() -> Void in
               
                    collectionView.reloadData()})
            break
        default:
            break
        }
    }
    
}
