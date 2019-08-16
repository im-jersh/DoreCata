//
//  AppleCoreDataStack.swift
//  DoreCata
//
//  Created by Joshua O'Steen on 8/16/19.
//  Copyright © 2019 Random Order. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {
    internal let persistentContainer: NSPersistentContainer
    
    internal let privateContext: NSManagedObjectContext
    
    public init(coreDataConfiguration: CoreDataConfigurable, completion: @escaping CoreDataInitializationHandler) {
        if let managedObjectModel = NSManagedObjectModel(contentsOf: coreDataConfiguration.managedObjectModelURL) {
            self.persistentContainer = NSPersistentContainer(name: coreDataConfiguration.storeName,
                                                             managedObjectModel: managedObjectModel)
        } else {
            self.persistentContainer = NSPersistentContainer(name: coreDataConfiguration.storeName)
        }
        
        self.persistentContainer.persistentStoreDescriptions = [coreDataConfiguration.persistentStoreType.storeDescription]
        
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            error == nil
                ? completion(.success(storeDescription))
                : completion(.failure(error!))
        }
        
        // Set up the context hierarchy
        self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        privateContext.automaticallyMergesChangesFromParent = true
        
        self.viewContext.parent = privateContext
        
        self.configureNotificationHandling()
    }
}

extension CoreDataStack: CoreDataStackInterface {
    public var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }
    

    public func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> ()) {
        self.persistentContainer.performBackgroundTask(task)
    }

    public func saveChanges(_ completion: @escaping (Result<Void, Error>) -> ()) {
        self.viewContext.performAndWait {
            if viewContext.hasChanges {
                let result = Result(catching: { try viewContext.save() })
                
                if case Result.failure(_) = result { completion(result) }
            }
        }
        
        let privateContext = self.privateContext
        privateContext.perform {
            // If the save from the view context failed, then there shouldn't be any changes
            if privateContext.hasChanges {
                completion(Result(catching: { try privateContext.save() }))
            }
        }
    }
}

extension CoreDataStack {
    private func configureNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChangesNotification(_:)), name: UIApplication.willTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChangesNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChangesNotification(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc private func saveChangesNotification(_ notificiation: NSNotification) {
        self.saveChanges { _ in }
    }
}
