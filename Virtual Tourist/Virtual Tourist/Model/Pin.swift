//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Reem on 5/27/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation


public class Pin: NSManagedObject {
    
    static let name = "Pin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: Pin.name, in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        }
        else {
            
            fatalError("Unable to find Entity name!")
        }
    }
    
}
