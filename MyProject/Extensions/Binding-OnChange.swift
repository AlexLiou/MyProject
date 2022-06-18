//
//  Binding-OnChange.swift
//  MyProject
//
//  Created by Alex Liou on 6/10/22.
//

import Foundation
import SwiftUI

extension Binding {
    
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding {
            self.wrappedValue
        } set: { newValue in
            self.wrappedValue = newValue
            handler()
        }
        
    }
}
