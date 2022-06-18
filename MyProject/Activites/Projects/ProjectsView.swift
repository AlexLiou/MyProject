//
//  ProjectsView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

class ProjectsViewModel: ObservableObject {
    static let tag: String? = "Home"
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
}

/// The Project View displayed on the HomeView when the tabs "Open" or "Closed" are selected.
struct ProjectsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var vm = ProjectsViewModel()
    let showClosedProjects: Bool
    let projects: FetchRequest<Project>
    let sortingKeyPaths = [
        \Item.itemTitle,
         \Item.itemCreationDate
    ]
    
    @State private var showingSortOrder = false
    @State private var sortOrder = Item.SortOrder.optimized
    
    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            SelectSomethingView()
        }
    }

    /// The struct that displays the various projects in their own section. Options in the top right and left
    /// for creating a new project and sorting respectively.
    var projectsList: some View {
        List {
            ForEach(projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: project)
                    }
                    if showClosedProjects == false {
                        /*
                         In iOS 14.3 VoiceOver has a glitch that reads the label
                         "Add Project as "Add" no matter what accessibility label
                         we give this project when using a label. As a result, when
                         VoiceOvewr is running we use a text view for hte button instead,
                         forcing a correct reading without losign the original layout.
                         */
                        Button(action: addProject) {
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
        .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
        .confirmationDialog(Text("Sort items"), isPresented: $showingSortOrder) {
            Button("Optimized") { sortOrder = .optimized }
            Button("Creation Date") { sortOrder = .creationDate }
            Button("Title") { sortOrder = .title }
        }
        .toolbar {
            addProjectToolbarItem
            sortProjectToolbarItem
        }
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
            if showClosedProjects == false {
                Button(action: addProject) {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    /// Creates new project and saves.
    func addProject() {
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
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
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)],
            predicate: NSPredicate(format: "closed = %d", showClosedProjects)
        )
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
