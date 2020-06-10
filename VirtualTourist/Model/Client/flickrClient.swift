//
//  flickrClient.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation
import UIKit


class flickrClient {
    
    static let apiKey = "96fd3daec16f3d5fb86bcb2b23bb79df"
    static let secretKey = "62d9773207c04617"
    
    enum Endpoint{
       static let flickrbaseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&"
       static let flickrApiKey = "api_key=\(flickrClient.apiKey)"
       static let flickrPoint = "&media=Photo&per_page=10&extras=url_m&format=json"
        
        
      case flickrSearchImageURL(Double, Double)
    
        
        var stringValue: String{
            switch self {
            case .flickrSearchImageURL(let lat,let lon):
                return Endpoint.flickrbaseURL + Endpoint.flickrApiKey + "&lat=\(lat)&lon=\(lon)" + Endpoint.flickrPoint
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getImageDetailsFromFlickr(lat: Double, lon: Double, completion: @escaping ([Photo], Error?) -> Void ) {
        taskGETRequest(url: Endpoint.flickrSearchImageURL(lat,lon).url, response: photoClass.self) { (response, error) in
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getImage(imageUrl: String, completion: @escaping(Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
            
        }
        task.resume()
    }
    
    
    class func taskGETRequest<Response: Decodable>(url: URL, response: Response.Type, completion: @escaping (Response?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let range = (14..<data.count)
                var newData = data.subdata(in: range)
                _ = newData.popLast()
                let object = try decoder.decode(Response.self, from: newData)
                DispatchQueue.main.async {
                    completion(object, nil)
                }
            } catch {
                do {
                    let failResponse = try decoder.decode(errorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, failResponse as? Error)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
}
