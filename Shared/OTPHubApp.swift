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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStore)
                .accentColor(.purple)
        }
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(appStore)
                .frame(minWidth: 300, idealWidth: 350, maxWidth: 350, minHeight: 400, idealHeight: 400, maxHeight: 500)
        }
        #endif
    }
}
