//
//  ItemRowView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

/// The Row created for Project View displaying the Item.
struct ItemRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                label
            } icon: {
                icon
            }
            .accessibilityLabel(label)
        }
    }
    
    /// Displays the select icon depending on the completion or priority of the item.
    /// Computed properties conventially have a constant complexity, O(1).
    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.triangle")
                .foregroundColor(Color(project.projectColor))
        } else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.clear)
        }
    }
    
    var label: Text {
        if item.completed {
            return Text("\(item.itemTitle), completed.")
        } else if item.priority == 3 {
            return Text("\(item.itemTitle), high priority.")
        } else {
            return Text(item.itemTitle)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}
