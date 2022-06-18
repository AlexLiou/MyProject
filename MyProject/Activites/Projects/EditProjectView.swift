//
//  EditProjectView.swift
//  MyProject
//
//  Created by Alex Liou on 6/11/22.
//

import SwiftUI

/// The view displayed when Editing a Project.
struct EditProjectView: View {
    let project: Project
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataController: DataController
    
    @State private var showingDeleteConfirm = false
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }
            Section(header: Text("Customer project color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
            Section {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }
                
                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(.red)
            } footer: {
                // swiftlint:disable:next line_length
                Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely")
            }
            
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete project?"),
                message: Text("Are you sure you want to delete this project?"),// swiftlint:disable:this line_length
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
    }

    /// Creates the Color Selector in the Edit Project View from Project.Colors
    /// Accessibilty Elements added to make obvious the colors are buttons and when it is
    /// selected.
    /// - Parameter item: String from Project.colors
    /// - Returns: View
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
            ? [.isButton, .isSelected] : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }

    /// Updates the contents on the project model with the
    /// TextField values.
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
    
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}