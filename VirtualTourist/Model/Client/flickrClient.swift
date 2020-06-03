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
       static let flickrPoint = "&media=Photo&per_page=3&format=json"
        
        
      case flickrSearchImageURL(Double, Double)
        case photoSourceURL(farmID:String, serverId:String, iD:String, secret:String)
        
        var stringValue: String{
            switch self {
            case .flickrSearchImageURL(let lat,let lon):
                return Endpoint.flickrbaseURL + Endpoint.flickrApiKey + "&lat=\(lat)&lon=\(lon)" + Endpoint.flickrPoint
            case .photoSourceURL(let farmId, let serverId, let iD, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(iD)_\(secret).jpg"
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
                print(response)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getImage(farmID: String, serverId: String, iD: String, secret: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoint.photoSourceURL(farmID: farmID, serverId: serverId, iD: iD, secret: secret).url) { (data, _, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let downloadedImage = UIImage(data: data)
            completion(downloadedImage, nil)
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
                newData.popLast()
                print(String(data: newData, encoding: .utf8)!)
                let object = try decoder.decode(Response.self, from: newData)
                DispatchQueue.main.async {
                    completion(object, nil)
                    print(object)
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
