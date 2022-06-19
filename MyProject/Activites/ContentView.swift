//
//  ContentView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

/// The main content View, uses a TabView to switch between the HomeView, ProjectsView (closed or open),
/// and AwardsView.
struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @SceneStorage("selectedView") var selectedView: String?

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(ProjectsView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }
            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
            AwardsView(dataController: dataController)
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
