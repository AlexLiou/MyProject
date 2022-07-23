//
//  AwardsViewModel.swift
//  MyProject
//
//  Created by Alex Liou on 7/22/22.
//

import Foundation
import SwiftUI
/*
 There are two ways of showing alerts in SwiftUI: waiting for a Boolean to become true,
 or waiting for an optional Identifiable property to change.
 Latter is preferable because it allows you to present data from that property in your alert.
 With the Boolean appraoch, you'd need to unwrap the optional or provide a sensible default yourself.
 We'll use both because we want to be able to pass along the selected award property.
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
