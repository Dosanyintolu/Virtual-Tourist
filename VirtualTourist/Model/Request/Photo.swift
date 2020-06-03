//
//  PhotoRequest.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation


struct Photo: Codable {
    
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    
    enum Codingkeys: String, CodingKey {
        
        case id
        case owner
        case secret
        case server
        case farm
        case title
    }
    
}
