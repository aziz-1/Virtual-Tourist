//
//  APIRequest.swift
//  Virtual Tourist
//
//  Created by Reem on 5/24/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct APIRequest: Codable {
    let method: String?
    let galleryID: String?
    let extras: [String]?
    let format: String?
    let safeSearch: String?
    let bbox: String?
    let photosPerPage: Int?
    let accuracy: Int?
    let page: Int?
    let apiKey: String
    let nojsoncallback: String?
    
    init(method: String, galleryID: String, extras: [String], format: String,  safeSearch: String, lat: Double, lon: Double, photosPerPage: Int, accuracy: Int, page: Int) {
        
        self.method = method
        self.galleryID = galleryID
        self.extras = extras
        self.format = format
        self.safeSearch = safeSearch
        
        self.bbox = Utility.bbox(lat: lat, lon: lon)
        self.photosPerPage = photosPerPage
        self.accuracy = accuracy
        self.page = page
        self.apiKey = "15314a4c4be63b2fd46ff58285ae3772"
        self.nojsoncallback = "1"
        
    }
    
    enum CodingKeys: String, CodingKey {
        case method
        case galleryID = "gallery_id"
        case extras
        case format
        case safeSearch = "safe_search"
        case bbox
        case photosPerPage = "per_page"
        case accuracy
        case page
        case apiKey = "oauth_consumer_key"
        case nojsoncallback
    }
    
   
}


