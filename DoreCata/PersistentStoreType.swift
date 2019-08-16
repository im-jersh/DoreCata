//
//  PersistentStoreType.swift
//  DoreCata
//
//  Created by Joshua O'Steen on 8/13/19.
//  Copyright © 2019 Random Order. All rights reserved.
//

import CoreData

public enum PersistentStoreType {
    case sqlite(storeURL: URL)
    case inMemory
}

extension PersistentStoreType {
    public var storeType: String {
        switch self {
        case .sqlite: return NSSQLiteStoreType
        case .inMemory: return NSInMemoryStoreType
        }
    }
    
    public var storeDescription: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.type = self.storeType
        
        switch self {
        case .sqlite(storeURL: let url):
            description.url = url
        case .inMemory:
            description.shouldAddStoreAsynchronously = false
        }
        
        return description
    }
}
