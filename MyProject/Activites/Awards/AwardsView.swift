//
//  AwardsView.swift
//  MyProject
//
//  Created by Alex Liou on 6/12/22.
//

import SwiftUI

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

// struct AwardsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AwardsView()
//    }
// }
