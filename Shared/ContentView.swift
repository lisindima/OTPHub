//
//  ContentView.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import OTP
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStore: AppStore

    @State private var isPresented: SheetState?

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { appStore.accounts[$0] }.forEach(appStore.removeAccount)
        }
    }

    private func binding(_ account: Account) -> Binding<Account> {
        guard let accountIndex = appStore.accounts.firstIndex(where: { $0.id == account.id }) else {
            fatalError("Can't find account in array")
        }
        return $appStore.accounts[accountIndex]
    }

    private func openSettings() {
        #if os(macOS)
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        #else
        isPresented = .settings
        #endif
    }

    private func openAddAccount() {
        isPresented = .addAccount
    }

    var body: some View {
        NavigationViewWrapper {
            List {
                ForEach(appStore.accounts, id: \.self) { account in
                    ListItem(account: binding(account))
                }
                .onDelete(perform: deleteItems)
            }
            .customListStyle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: openAddAccount) {
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
                SettingsView()
                    .accentColor(.purple)
            case .addAccount:
                AddAccountView()
                    .accentColor(.purple)
            }
        }
    }
}
