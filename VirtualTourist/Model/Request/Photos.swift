//
//  PhotosRequest.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation

struct photoClass: Codable {
    let photos: Photos
    let stat: String
    
    enum CodingKeys: String, CodingKey {
           case photos
           case stat
       }
}
struct Photos: Codable {
    
    var page: Int
    var pages: Int
    var perPage: Int
    var total: String
    var photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
        
    }
}
