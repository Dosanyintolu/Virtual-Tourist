//
//  PhotosRequest.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation


struct Photos: Codable {
    
    var page: Int
    var pages: String
    var perPage: Int
    var total: String
    var photo: [Photo]
    
}
