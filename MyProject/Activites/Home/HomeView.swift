//
//  HomeView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI
import CoreData
import CoreSpotlight

/*
 Almost all logic now comes out from the view, meaning that
 all sorts of logic can now be tested without resorting to UI tests.
 Even better, Core Data is now an implementation detail of our view models
 - we could replace it with flat JSON if we wanted and neither
 HomeView or ProjectsView would care.
 */

/// The HomeView displays the most high priority items and a Project Summary View at the top
struct HomeView: View {
    @StateObject var vm: ViewModel

    static let tag: String? = "Home"

    var body: some View {
        NavigationView {
            ScrollView {
                if let item = vm.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $vm.selectedItem,
                        label: EmptyView.init
                    )
                    .id(item)
                }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(vm.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: false)
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: vm.upNext)
                        ItemListView(title: "More to explore", items: vm.moreToExplore)
                    }
                    .padding(.horizontal)
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                Button("Add Data", action: vm.addSampleData)
            }

        }
    }

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects.
    init(dataController: DataController) {
        let vm = ViewModel(dataController: dataController)
        _vm = StateObject(wrappedValue: vm)
    }

    /// Accepts a NSUserActivity then looks inside the data to find the unique identifier from spotlight.
    /// - Parameter userActivity: <#userActivity description#>
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            vm.selectItem(with: uniqueIdentifier)
        }
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
