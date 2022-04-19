//
//  StorageManager.swift
//  ToDoListCoreData
//
//  Created by Sergey Runovich on 19.04.22.
//

import CoreData

class StorageManager {

    static let shared = StorageManager()

    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoListCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {}
}

extension StorageManager {

    // MARK: - Public Methods
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func editTask(_ task: Task, newName: String) {
        task.info = newName
        saveContext()
    }

    func deleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
    }

    func saveTask(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.info = taskName

        completion(task)
        saveContext()
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

