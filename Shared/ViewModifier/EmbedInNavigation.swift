//
//  EmbedInNavigation.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct EmbedInNavigation: ViewModifier {
    var title: LocalizedStringKey
    var displayMode: NavigationBarItem.TitleDisplayMode
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle(title)
        #elseif os(iOS)
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(displayMode)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        NavigationView {
            content
                .navigationTitle(title)
        }
        #endif
    }
}
