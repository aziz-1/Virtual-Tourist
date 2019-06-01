//
//  UdacityClient.swift
//  Virtual Tourist
//
//  Created by Reem on 5/23/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let container:NSPersistentContainer
    
    var context:NSManagedObjectContext {
        return container.viewContext
    }

    init(modelName:String) {
        self.container = NSPersistentContainer(name: modelName)
        
    }

    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { store, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
         
            completion?()
        }
    }
}

