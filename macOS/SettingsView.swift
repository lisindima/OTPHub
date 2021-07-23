//
//  SettingsView.swift
//  OTPHub (macOS)
//
//  Created by Дмитрий Лисин on 27.02.2021.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Text("Главная")
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
            Text("База данных")
                .tabItem {
                    Label("База данных", systemImage: "house")
                }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
