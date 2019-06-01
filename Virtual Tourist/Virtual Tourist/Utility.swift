//
//  Utility.swift
//  Virtual Tourist
//
//  Created by Reem on 5/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    class func bbox(lat: Double, lon: Double) -> String {
        
        let minLon = max(lon - 0.2, -180.0)
        let minLat = max(lat  - 0.2, -90.0)
        let maxLon = min(lon + 0.2, 180.0)
        let maxLat = min(lat  + 0.2, 90.0)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    static func returnStringURL(request: APIRequest) -> String? {
        
        return "?method=\(request.method!)&oauth_consumer_key=\(request.apiKey)&bbox=\(request.bbox!)&accuracy=\(request.accuracy!)&safe_search=\(request.safeSearch!)&media=photos&extras=url_n&per_page=\(request.photosPerPage!)&page=\(request.page!)&format=json&nojsoncallback=1"
    }
    
    static func showAlert(message: String, controller: UIViewController) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
}

