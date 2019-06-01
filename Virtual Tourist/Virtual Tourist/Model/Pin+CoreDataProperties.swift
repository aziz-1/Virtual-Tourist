//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Reem on 5/27/19.
//  Copyright © 2019 Udacity. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension Pin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Image)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Image)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
