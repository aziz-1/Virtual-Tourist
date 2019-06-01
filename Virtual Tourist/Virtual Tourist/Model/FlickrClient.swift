//
//  UdacityClient.swift
//  Virtual Tourist
//
//  Created by Reem on 5/23/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class FlickrClient {
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                  
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    
                    completion(responseObject, nil)
                }
            } catch {
                
                completion(nil, error)
                
            }
        }
        task.resume()
        
        return task
    }
    
    class func getPhotos(body: APIRequest, completion: @escaping (Photos?, Error?) -> Void) {
        var fullURL = Endpoints.base
        if let url =  Utility.returnStringURL(request: body) {
            fullURL = fullURL + url
            
        }
        taskForGETRequest(url: URL(string:fullURL) ?? URL(string: "")!, responseType: Photos.self) { (response, error) in
            if let response = response {
              
                completion(response, nil)
                
            }
            else {
                completion(nil, error)
            }
            
            
        }
    }
    
}
