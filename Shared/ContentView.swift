//
//  ContentView.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import KeychainOTP
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStore: AppStore

    @State private var showSettings: Bool = false
    @State private var showAccount: Bool = false
    @State private var search: String = ""

    var body: some View {
        NavigationViewWrapper {
            List {
                ForEach($appStore.accounts) { $account in
                    ListItem(account: $account)
                }
                .onDelete(perform: deleteItems)
            }
            .environment(\.defaultMinListRowHeight, 70)
            .searchable(text: $search)
            .refreshable {
                appStore.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAccount = true
                    } label: {
                        Label("Add account", systemImage: "plus.circle.fill")
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    .help("Add new account")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        openSettings()
                    } label: {
                        Label("Settings", systemImage: "ellipsis")
                    }
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Open settings")
                }
            }
            .navigationTitle("OTPHub")
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAccount) {
                AddAccountView()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { appStore.accounts[$0] }.forEach(appStore.removeAccount)
        }
    }

    private func openSettings() {
        #if os(macOS)
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        #else
        showSettings = true
        #endif
    }
}
