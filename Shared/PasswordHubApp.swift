//
//  PasswordHubApp.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

@main
struct PasswordHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.purple)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
