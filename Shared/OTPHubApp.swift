//
//  OTPHubApp.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

@main
struct OTPHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.purple)
                .onOpenURL { url in
                    print(url)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
