//
//  ItemListView.swift
//  MyProject
//
//  Created by Alex Liou on 6/13/22.
//

import SwiftUI

/// The Item List rows displayed in the Home View
struct ItemListView: View {
    let title: LocalizedStringKey
    let items: ArraySlice<Item>

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    itemList(for: item)
                }
            }
        }
    }

    /// Creates an entry in the itemList, with a Circle and then a cursory glance
    /// of the item.
    /// - Parameter item: The item being displayed
    /// - Returns: The view.
    func itemList(for item: Item) -> some View {
        HStack(spacing: 20) {
            Circle()
                .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if item.itemDetail.isEmpty == false {
                    Text(item.itemDetail)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
    }
}

// struct ItemListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemListView()
//    }
// }
