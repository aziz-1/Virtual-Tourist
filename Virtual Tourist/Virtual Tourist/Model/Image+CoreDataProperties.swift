//
//  Image+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Reem on 5/27/19.
//  Copyright © 2019 Udacity. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var picture: NSData?
    @NSManaged public var pin: Pin?

}
