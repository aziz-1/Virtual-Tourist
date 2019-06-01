//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Reem on 5/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos:Photo?
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
    
 
}

struct Photo: Codable {
    let photo: [APIResponse]?
    
    enum CodingKeys: String, CodingKey {
        case photo
    }
}
