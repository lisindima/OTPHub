//
//  ContentView.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStore: AppStore

    @State private var isPresented: SheetState?

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { appStore.accounts[$0] }.forEach(appStore.removeAccount)
        }
    }
    
    private func openSettings() {
        #if os(macOS)
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        #else
        isPresented = .settings
        #endif
    }
    
    private func openAddPassword() {
        isPresented = .addpassword
    }

    var body: some View {
        NavigationViewWrapper {
            List {
                ForEach(appStore.accounts, id: \.id, content: ListItem.init)
                    .onDelete(perform: deleteItems)
            }
            .customListStyle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: openAddPassword) {
                        Label("button_title_add_account", systemImage: "plus.circle.fill")
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    .help("help_title_add_button")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: openSettings) {
                        Label("button_title_settings", systemImage: "ellipsis")
                    }
                    .keyboardShortcut("s", modifiers: .command)
                    .help("help_title_settings_button")
                }
            }
            .navigationTitle("OTPHub")
        }
        .sheet(item: $isPresented) { view in
            switch view {
            case .settings:
                #if os(iOS)
                SettingsView()
                    .accentColor(.purple)
                #endif
            case .addpassword:
                AddPasswordView()
                    .accentColor(.purple)
            }
        }
    }
}
