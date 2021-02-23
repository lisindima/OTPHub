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
    
    var body: some View {
        NavigationViewWrapper {
            List {
                ForEach(appStore.accounts, id: \.id, content: ListItem.init)
                    .onDelete(perform: deleteItems)
            }
            .customListStyle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isPresented = .addpassword }) {
                        Label("button_title_add_account", systemImage: "plus.circle.fill")
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    .help("help_title_add_button")
                }
                #if os(iOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { isPresented = .settings }) {
                        Label("button_title_settings", systemImage: "ellipsis")
                    }
                    .keyboardShortcut("s", modifiers: .command)
                }
                #endif
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
