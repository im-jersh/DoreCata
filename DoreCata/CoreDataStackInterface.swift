//
//  CoreDataStackInterface.swift
//  DoreCata
//
//  Created by Joshua O'Steen on 8/13/19.
//  Copyright © 2019 Random Order. All rights reserved.
//

import CoreData

public protocol CoreDataStackInterface {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> ())
    func saveChanges(_ notification: NSNotification?) throws
}
