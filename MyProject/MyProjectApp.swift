//
//  MyProjectApp.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import SwiftUI

@main
struct MyProjectApp: App {
    // @StateObject because our app will create and own the data controller,
    // ensuring it stays alive for the duration of the our app's runtime.
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
            // Connects CoreData to SwifutUI by letting SwiftUI know where to look for the data
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
                /*
                 Automatically save when we detect that we are
                 no longer the foreground app. Use this rather than
                 scene phase wo we can port to macOS, where scene
                 phase won't detect our app losing focus.
                 */
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
                .onAppear(perform: dataController.appLaunched)
        }
    }

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }

    func save(_ note: Notification) {
        dataController.save()
    }
}
