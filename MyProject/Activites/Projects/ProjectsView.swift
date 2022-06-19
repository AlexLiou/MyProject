//
//  ProjectsView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI
import CoreData
import Foundation

extension ProjectsView {
    class ViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
        let dataController: DataController
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        let showClosedProjects: Bool
        @Published var sortOrder = Item.SortOrder.optimized

        /// Creates new project and saves.
        func addProject() {
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
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

/// The Project View displayed on the HomeView when the tabs "Open" or "Closed" are selected.
struct ProjectsView: View {
    @StateObject var vm: ViewModel
    static let tag: String? = "Home"
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    let sortingKeyPaths = [
        \Item.itemTitle,
         \Item.itemCreationDate
    ]
    
    @State private var showingSortOrder = false
    
    var body: some View {
        NavigationView {
            Group {
                if vm.projects.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(vm.showClosedProjects ? "Closed Projects" : "Open Projects")
            .confirmationDialog(Text("Sort items"), isPresented: $showingSortOrder) {
                Button("Optimized") { vm.sortOrder = .optimized }
                Button("Creation Date") { vm.sortOrder = .creationDate }
                Button("Title") { vm.sortOrder = .title }
            }
            .toolbar {
                addProjectToolbarItem
                sortProjectToolbarItem
            }
            SelectSomethingView()
        }
    }

    /// The struct that displays the various projects in their own section. Options in the top right and left
    /// for creating a new project and sorting respectively.
    var projectsList: some View {
        List {
            ForEach(vm.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: vm.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        vm.delete(offsets, from: project)
                    }
                    if vm.showClosedProjects == false {
                        /*
                         In iOS 14.3 VoiceOver has a glitch that reads the label
                         "Add Project as "Add" no matter what accessibility label
                         we give this project when using a label. As a result, when
                         VoiceOvewr is running we use a text view for hte button instead,
                         forcing a correct reading without losign the original layout.
                         */
                        Button {
                            withAnimation {
                                vm.addItem(to: project)
                            }
                        } label: {
                            if UIAccessibility.isVoiceOverRunning {
                                Text("Add Project")
                            } else {
                                Label("Add New Item", systemImage: "plus")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    /// The Toolbar button for displaying sort options.
    var sortProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    /// The Toolbar button for displaying add project option.
    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if vm.showClosedProjects == false {
                Button {
                    withAnimation {
                        vm.addProject()
                    }
                } label: {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    init(dataController: DataController, showClosedProjects: Bool) {
        let vm = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _vm = StateObject(wrappedValue: vm)
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(dataController: DataController.preview, showClosedProjects: false)
    }
}
