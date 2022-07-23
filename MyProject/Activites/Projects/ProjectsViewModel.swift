//
//  ProjectsViewModel.swift
//  MyProject
//
//  Created by Alex Liou on 7/22/22.
//

import Foundation
import SwiftUI
import CoreData

extension ProjectsView {
    class ViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
        let dataController: DataController
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        let showClosedProjects: Bool
        @Published var sortOrder = Item.SortOrder.optimized
        @Published var showingUnlockView = false

        /// Creates new project and saves.
        func addProject() {
            if dataController.addProject() == false {
                showingUnlockView.toggle()
            }
        }

        func delete(_ offsets: IndexSet, from project: Project) {
            let allItems = project.projectItems(using: sortOrder)

            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }

            dataController.save()
        }

        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }

        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }

        }
    }
}
