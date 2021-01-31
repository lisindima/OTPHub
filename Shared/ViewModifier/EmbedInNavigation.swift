//
//  EmbedInNavigation.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct EmbedInNavigation: ViewModifier {
    var title: LocalizedStringKey
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle(title)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: nil, minHeight: 340, idealHeight: 440, maxHeight: nil)
        #else
        NavigationView {
            content
                .navigationTitle(title)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
