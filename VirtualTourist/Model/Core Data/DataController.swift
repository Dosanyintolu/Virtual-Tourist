//
//  DataController.swift
//  VirtualTourist
//
//  Created by Doyinsola Osanyintolu on 5/26/20.
//  Copyright © 2020 DoyinOsanyintolu. All rights reserved.
//

import Foundation
import CoreData



class DataController {
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
    func autoSaveViewContext(time interval: TimeInterval = 30) {
        guard interval > 0 else {
            print("Unable to autosave")
            return
        }
        
        if viewContext.hasChanges {
            print("Save made")
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(time: interval)
        }
    }
}
