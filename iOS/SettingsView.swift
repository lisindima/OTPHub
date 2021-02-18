//
//  SettingsView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 18.02.2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var appVersion: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return Text("\(version) (\(build))")
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: appVersion) {
                    NavigationLink(destination: Text("Лицензии")) {
                        Label("Лицензии", systemImage: "doc.plaintext")
                    }
                }
            }
            .navigationTitle("navigation_title_settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismissView) {
                        Label("close_toolbar", systemImage: "xmark")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
