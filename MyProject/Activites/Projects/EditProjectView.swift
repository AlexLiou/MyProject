//
//  EditProjectView.swift
//  MyProject
//
//  Created by Alex Liou on 6/11/22.
//

import SwiftUI
import CoreHaptics

/// The view displayed when Editing a Project.
struct EditProjectView: View {
    let project: Project

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataController: DataController

    @State private var showingDeleteConfirm = false
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var engine = try? CHHapticEngine()
    @State private var remindMe: Bool
    @State private var reminderTime: Date
    @State private var showingNotificationsError = false

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
            Section(header: Text("Project reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))

                if remindMe {
                    DatePicker(
                        "Reminder time",
                        selection: $reminderTime.onChange(update),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .alert(isPresented: $showingNotificationsError) {
                Alert(
                    title: Text("Oops!"),
                    message: Text("There was a problem. Please check you have notifications enabled."),
                    primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                    secondaryButton: .cancel()
                )
            }
            Section {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }

                Button("Delete this project", action: toggleClosed)
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
                message: Text("Are you sure you want to delete this project?"),
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

        if remindMe {
            project.reminderTime = reminderTime

            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false

                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    func toggleClosed() {
        project.closed.toggle()

        if project.closed {
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                // use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                // create a continuous haptic event starting immediately and lasting one second
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)

            } catch {
                // playing haptics didn't work, but that's okay
            }
        }
    }

    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(initialValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }
}

//struct EditProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProjectView(project: Project.example)
//    }
//}
