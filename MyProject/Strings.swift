//
//  Strings.swift
//  MyProject
//
//  Created by Alex Liou on 6/14/22.
//

import SwiftUI

enum Strings: LocalizedStringKey {
    case appWelcomeMessage
    case updateSettings
}

extension Text {
    init(_ localizedString: Strings, tableName: String) {
        self.init(localizedString.rawValue, tableName: tableName)
    }
}

struct test: View {
    
    var body: some View {
        VStack {
            Text(.appWelcomeMessage, tableName: "Main")
            Text(.updateSettings, tableName: "Buttons")
        }
    }
}

/*
 
 Localizable files can look like:
 "updateSettings" = "Settings";
 "appWelcomeMessage" = "Welcome to the app!";
 */
