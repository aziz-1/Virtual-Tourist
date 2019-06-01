//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Reem on 5/27/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  let dataController = DataController(modelName: "Virtual Tourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        
        let notebookController = navigationController.topViewController as! MainViewController
        
        notebookController.dataController = dataController
        return true
    }

  

}

