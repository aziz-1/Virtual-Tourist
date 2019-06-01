//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Reem on 5/27/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let pStroe:NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return pStroe.viewContext
    }
    
    init(modelName:String) {
        pStroe = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        pStroe.loadPersistentStores { (store, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
