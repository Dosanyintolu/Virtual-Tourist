//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/23/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation


struct errorResponse: Codable {
    var status: String
    var code: Int
    var message: String
    
    
    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case code
        case message
    }
}
