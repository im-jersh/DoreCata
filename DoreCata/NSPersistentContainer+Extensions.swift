//
//  NSPersistentContainer+Extensions.swift
//  DoreCata
//
//  Created by Joshua O'Steen on 8/13/19.
//  Copyright © 2019 Random Order. All rights reserved.
//

import CoreData

extension NSPersistentContainer: CoreDataStackInterface {
    public convenience init(coreDataConfiguration: CoreDataConfigurable, completion: @escaping CoreDataInitializationHandler) {
        
        if let managedObjectModel = NSManagedObjectModel(contentsOf: coreDataConfiguration.managedObjectModelURL) {
            self.init(name: coreDataConfiguration.storeName, managedObjectModel: managedObjectModel)
        } else {
            self.init(name: coreDataConfiguration.storeName)
        }
        
        self.persistentStoreDescriptions = [coreDataConfiguration.persistentStoreType.storeDescription]
        
        self.loadPersistentStores { (storeDescription, error) in
            error == nil
                ? completion(.success(storeDescription))
                : completion(.failure(error!))
        }
    }
    
    public func saveChanges(_ completion: @escaping (Result<Void, Error>) -> ()) {
        let context = self.viewContext
        context.perform {
            if context.hasChanges {
                completion(Result(catching: { try context.save() }))
            }
        }
    }
}
