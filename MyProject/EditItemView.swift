//
//  EditItemView.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

class EditItemViewModel: ObservableObject {
    
}

struct EditItemView: View {
    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool
    let item: Item
    @StateObject var vm = EditItemViewModel()
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Item name", text: $title.onChange(update))
                TextField("Description", text: $detail.onChange(update))
            }
            
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority.onChange(update)) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                Toggle("Mark Completed", isOn: $completed.onChange(update))
            }
        }
        .navigationTitle("Edit Item")
        .onDisappear(perform: dataController.save)
    }
    
    init(item: Item) {
        self.item = item
        
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }
    
    func update() {
        item.project?.objectWillChange.send()
        
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
}
//
//struct EditItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditItemView(item: Item.example)
//    }
//}
