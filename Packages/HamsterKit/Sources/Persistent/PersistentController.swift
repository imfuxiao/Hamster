//
//  PersistentController.swift
//  HamsterApp
//
//  Created by morse on 16/3/2023.
//

import CoreData

struct PersistentController {
  static let shared = PersistentController()

  let container: NSPersistentContainer
  init() {
    let name = "HamsterApp"

    let storeURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)!
      .appendingPathComponent("\(name).sqlite")

    let storeDescription = NSPersistentStoreDescription(url: storeURL)
    container = NSPersistentContainer(name: name)
    container.persistentStoreDescriptions = [storeDescription]
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
  }
}
