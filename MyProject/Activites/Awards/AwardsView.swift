//
//  AwardsView.swift
//  MyProject
//
//  Created by Alex Liou on 6/12/22.
//

import SwiftUI

/*
 There are two ways of showing alerts in SwiftUI: waiting for a Boolean to become true, or waiting for an optional Identifiable property
 to change. Latter is preferable because it allows you to present data from that property in your alert. With the Boolean appraoch, you'd need to unwrap the optional or provide a sensible default yourself. We'll use both because we want to be able to pass along the selected award property.
 */

extension AwardsView {
    class ViewModel: ObservableObject {
        let dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
        }

        /// Checks if the award has been earned, if so returns the right color, else returns a faded color to show
        /// the order has not been earned.
        /// - Parameter award: the award selected
        /// - Returns: Color, determined by the award.
        func color(for award: Award) -> Color {
            dataController.hasEarned(award: award) ? Color(award.color) : Color.secondary.opacity(0.5)
        }

        /// Checks if the award has been earned, if so returns "Unlocked", if not return "Locked"
        /// - Parameter award: the award selected
        /// - Returns: Text
        func label(for award: Award) -> Text {
            Text(dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked")
        }

        func hasEarned(award: Award) -> Bool {
            dataController.hasEarned(award: award)
        }
    }
}

struct AwardsView: View {
    
    @StateObject var vm: ViewModel
    
    static let tag: String? = "Awards"
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(vm.color(for: award))
                        }
                        .accessibilityLabel(vm.label(for: award))
                        .accessibilityHint(Text(award.description))
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails, content: getAwardAlert)
        
    }

    /// Returns an Alert to show the description of the selected Award.
    /// - Returns: Alert with content of the Award explaining the details.
    func getAwardAlert() -> Alert {
        if vm.dataController.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(
                title: Text("Locked"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    init(dataController: DataController) {
        let vm = ViewModel(dataController: dataController)
        _vm = StateObject(wrappedValue: vm)
    }
}

//struct AwardsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AwardsView()
//    }
//}
