//
//  photoAlbumVC+extension.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 6/3/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation
import UIKit

extension photoAlbumViewController {
    
    func downloadImageDetailsFromFlickr() {
        flickrClient.getImageDetailsFromFlickr(lat: 32.8297529087073, lon: -98.30174486714975) { (photo, error) in
            if error == nil {
                print(photo)
                let flickr = FlickrImage(context: self.dataController.viewContext)
                for i in photo {
                    flickr.id = i.id
                    flickr.owner = i.owner
                    flickr.server = i.server
                    flickr.secret = i.secret
                }
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? "Error in the fetch image block")
                print("problem in downloading details.")
            }
        }
    }
    
}
