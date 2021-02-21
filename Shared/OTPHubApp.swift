//
//  OTPHubApp.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

@main
struct OTPHubApp: App {
    @StateObject private var appStore = AppStore.shared
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStore)
                .accentColor(.purple)
                .onOpenURL { url in
                    print(url)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
