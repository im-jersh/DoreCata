//
//  CoreDataConfiguration.swift
//  DoreCata
//
//  Created by Joshua O'Steen on 8/13/19.
//  Copyright © 2019 Random Order. All rights reserved.
//

import CoreData

public typealias CoreDataInitializationHandler = (Result<NSPersistentStoreDescription, Error>) -> Void

public protocol CoreDataConfigurable {
    var modelName: String { get }
    var storeName: String { get }
    var managedObjectModelURL: URL { get }
    var persistentStoreType: PersistentStoreType { get }
}

public extension CoreDataConfigurable {
    var modelName: String { return Self.defaultModelName }
    
    var storeName: String { return Self.defaultStoreName }
    
    var managedObjectModelURL: URL { return Self.defaultManagedObjectModelURL }
    
    var persistentStoreType: PersistentStoreType { return .sqlite(storeURL: Self.defaultPersistentStoreURL) }
}

internal extension CoreDataConfigurable {
    
    static var defaultModelName: String {
        guard let bundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else {
            preconditionFailure("CoreDataConfigurable Default Implementation: The main bundle appears to improperly configured. It is missing a value for the key `CFBundleDisplayName`")
        }
        return bundleDisplayName
    }
    
    static var defaultStoreName: String { return Self.defaultModelName }
    
    static var defaultManagedObjectModelURL: URL {
        guard let modelURL = Bundle.main.url(forResource: Self.defaultModelName, withExtension: "momd") else {
            preconditionFailure("CoreDataConfigurable Default Implementation: Unable to load model from the main bundle")
        }
        return modelURL
    }
    
    static var defaultPersistentStoreURL: URL { return NSPersistentContainer.defaultDirectoryURL() }
}
