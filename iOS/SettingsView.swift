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
        return Text("section_footer_app_version \(version) (\(build))")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button {
                        isExporting = true
                    } label: {
                        Label("button_title_export_account", systemImage: "externaldrive.badge.timemachine")
                    }
                    Button {
                        isImporting = true
                    } label: {
                        Label("button_title_import_account", systemImage: "internaldrive")
                    }
                } header: {
                    Text("section_header_database")
                } footer: {
                    Text("section_footer_database")
                }
                Section {
                    NavigationLink(destination: License()) {
                        Label("navigation_link_license", systemImage: "doc.plaintext")
                    }
                } header: {
                    Text("section_header_other")
                } footer: {
                    appVersion
                }
            }
            .navigationTitle("navigation_title_settings")
            .customAlert(item: $alertItem)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Text("close_toolbar")
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
                    alertItem = AlertItem(title: "alert_success_title", message: "alert_success_create_backup")
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
