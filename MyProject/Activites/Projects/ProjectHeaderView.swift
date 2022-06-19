//
//  ProjectHeaderView.swift
//  MyProject
//
//  Created by Alex Liou on 6/11/22.
//

import SwiftUI

/// The proejct header part of the Projects View. Displays the title and a progress
/// bar showing how far the project is towards completion. Contains a link to Edit the project.
struct ProjectHeaderView: View {
    @ObservedObject var project: Project

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(project.projectTitle)

                ProgressView(value: project.completionAmount)
                    .accentColor(Color(project.projectColor))
            }

            Spacer()

            NavigationLink(destination: EditProjectView(project: project)) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
        }
        .padding(.bottom, 10)
        .accessibilityElement(children: .combine)
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectHeaderView(project: Project.example)
    }
}
