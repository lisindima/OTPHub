//
//  SettingsView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 18.02.2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var appStore: AppStore

    @State private var isExporting: Bool = false
    @State private var isImporting: Bool = false
    @State private var alertItem: AlertItem?

    private var appVersion: Text {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return Text("Version: \(version) (\(build))")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button {
                        isExporting = true
                    } label: {
                        Label("Export accounts", systemImage: "externaldrive.badge.timemachine")
                    }
                    Button {
                        isImporting = true
                    } label: {
                        Label("Import accounts", systemImage: "internaldrive")
                    }
                } header: {
                    Text("Database")
                } footer: {
                    Text("Use this for backups or to move to other devices outside of your iCloud account.")
                }
                Section {
                    NavigationLink(destination: License()) {
                        Label("License", systemImage: "doc.plaintext")
                    }
                } header: {
                    Text("Other")
                } footer: {
                    appVersion
                }
            }
            .navigationTitle("Settings")
            .customAlert(item: $alertItem)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Text("Close")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .fileExporter(
                isPresented: $isExporting,
                document: AccountDocument(account: appStore.accounts),
                contentType: UTType("com.darkfox.otphub.backup")!,
                defaultFilename: "Backup"
            ) { result in
                switch result {
                case .success:
                    alertItem = AlertItem(title: "Success", message: "The backup was saved successfully.")
                case let .failure(error):
                    print(error)
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType("com.darkfox.otphub.backup")!],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case let .success(url):
                    appStore.importAccountInKeychain(url.first)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
