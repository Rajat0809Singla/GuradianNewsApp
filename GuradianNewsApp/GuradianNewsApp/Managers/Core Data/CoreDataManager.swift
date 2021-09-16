//
//  CoreDataManager.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation
import CoreData

final class CoreDataManager: NSObject {

    private static let dataBaseName = "NewsList"

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "NewsList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectPrivateQueueContext.hasChanges {
            do {
                try managedObjectPrivateQueueContext.save()

                managedObjectMainQueueContext.performAndWait {
                    do {
                        try managedObjectMainQueueContext.save()
                    } catch {
                        fatalError("Failure to save managedObjectcontext: \(error)")
                    }
                }
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("managedObjectPrivateQueueContext \(nserror), \(nserror.userInfo)")
            }
        }
    }

    lazy var managedObjectModel: NSManagedObjectModel = {

        if #available(iOS 10.0, *) {
            return persistentContainer.managedObjectModel
        } else {
            // iOS 9.0 and below - however you were previously handling it
            guard let modelURL = Bundle.main.url(forResource: CoreDataManager.dataBaseName, withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            return mom
        }
    }()

    lazy var managedObjectMainQueueContext: NSManagedObjectContext = {
        var context: NSManagedObjectContext

        if #available(iOS 10.0, *) {
            context = persistentContainer.viewContext
            persistentContainer.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
            persistentContainer.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        } else {
            // iOS 9.0 and below - however you were previously handling it
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        return context
    }()

    lazy var managedObjectPrivateQueueContext: NSManagedObjectContext = {
        var context: NSManagedObjectContext

        if #available(iOS 10.0, *) {
            context = persistentContainer.newBackgroundContext()
            persistentContainer.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
            persistentContainer.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        } else {
            // iOS 9.0 and below - however you were previously handling it
            context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        return context
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        if #available(iOS 10.0, *) {
            return persistentContainer.persistentStoreCoordinator
        }
        else {
            // iOS 9.0 and below - however you were previously handling it
            let mom = managedObjectModel

            // handle db upgrade
            let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                            NSInferMappingModelAutomaticallyOption: true]

            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent(CoreDataManager.dataBaseName + ".sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: mOptions)
            } catch {
                fatalError("Error adding persistent store: \(error)")
            }
            return psc
        }
    }()
}
