//
//  OTPHubApp.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

@main
struct OTPHubApp: App {
    @State private var openAddPasswordView: Bool = false
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(isPresented: $openAddPasswordView)
                .accentColor(.purple)
                .onOpenURL { url in
                    print(url)
                    openAddPasswordView = true
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
