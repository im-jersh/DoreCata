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
    
    internal var storeType: String {
        switch self {
        case .sqlite: return NSSQLiteStoreType
        case .inMemory: return NSInMemoryStoreType
        }
    }
}
