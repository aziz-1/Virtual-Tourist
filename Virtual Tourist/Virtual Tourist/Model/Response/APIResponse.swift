//
//  APIResponse.swift
//  Virtual Tourist
//
//  Created by Reem on 5/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct APIResponse: Codable {
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        
    }
}
