//
//  DataController.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI
import CoreData
import CoreSpotlight
import UserNotifications
import StoreKit

/// An environment singleton responsible for manaing our Core Data stack, including handling saving,
/// counting fetch request, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container responsible for loading and managing local data using CoreData, synced to iCloud
    let container: NSPersistentCloudKitContainer

    // The UserDefaults suit where we're saving user data.
    let defaults: UserDefaults

    // Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }

        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    /// Initializes a data controller, either in memeory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.) Defaults to permanent storage.
    ///  - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        /*
         For testing and previewing purposes, we create a temporary, in-memory database
         by writing to /dev/null so our data is destoryed after the app finishes running.
         */
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()

            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        // tells CoreData to write all those new objects to the persistent storage.
        try viewContext.save()
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fata error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func delete(_ object: Project) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])

        container.viewContext.delete(object)
    }

    func delete(_ object: Item) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])

        container.viewContext.delete(object)
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Checks if the user has fulfilled the criterion on the award and returns true or false.
    /// - Parameter award: The award from Awards.json
    /// - Returns: Bool value, true if user has fulfilled the criterion, false if not.
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            // returns ture if they added a certain number of items.
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "complete":
            // returns true if they completed a certain number of items.
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        default:
            // an unknown award criterion; this should never be allowed.
            // fatalError("Unknown award criterion \(award.criterion).")
            return false
        }
    }

    /// Writing data with Core Spotlight takes four small steps.
    /// 1. Creating a unique identifier for the item you want to save.
    /// If you’re updating an existing item you should use the same identifier.
    /// 2. Decide what attributes you want to store in Spotlight. There are hundreds of these to choose from
    /// , but you’ll probably want title and description at the very least.
    /// 3. Wrap up the identifier and attributes in a Spotlight record, also passing in a domain identifier
    /// – a way to group certain pieces of data together.
    /// 4.Send that off to Spotlight for indexing.
    /// - Parameter item: <#item description#>
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    /// Converts uniqueIdentifier into an Item instance.
    /// - Parameter uniqueIdentifier: <#uniqueIdentifier description#>
    /// - Returns: <#description#>
    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }

    /// Adds notification to a project.
    ///
    /// First check our authorization status for local notifications. If the status is not determined,
    /// If we are already authorized, we can call placeReminders() immediately. If we're in any
    /// other authorization state, call failure, user has not granted us permission.
    /// - Parameters:
    ///   - project: The project being added a reminder
    ///   - completion: handler
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removes notifications that are set for a single proejct
    /// - Parameters:
    ///   - project: container for the unique objectID
    func removeReminders(for project: Project) {
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Requests notifcation authorization from iOS, asking to be able to show
    /// an alert and play a sound, then call the completion handler with whatever
    /// the system replies back with
    /// - Parameter completion: completion handler
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    /// Decides the content of the notification, tells the iOS when the notification should be shown,
    /// wraps up those two pieces of info along with a unique identifier, then send it off to IOS to be shown
    /// - Parameters:
    ///   - project: the project in question
    ///   - completion: handler
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // send notification request to iOS
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    /// Finds the first active scene (the one that's currently receiving user input) then asks for a review prompt
    /// to appear there.
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3

        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }
}
