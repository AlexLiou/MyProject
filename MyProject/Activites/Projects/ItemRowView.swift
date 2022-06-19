//
//  ItemRowView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

/// The Row created for Project View displaying the Item.
struct ItemRowView: View {
    @StateObject var vm: ViewModel
    @ObservedObject var item: Item

    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(vm.title)
            } icon: {
                Image(systemName: vm.icon)
                    .foregroundColor(vm.color.map { Color($0) } ?? .clear)
            }
            .accessibilityLabel(vm.label)
        }
    }

    init(project: Project, item: Item) {
        let vm = ViewModel(project: project, item: item)
        _vm = StateObject(wrappedValue: vm)

        self.item = item
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}
