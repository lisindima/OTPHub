//
//  EmbedInNavigation.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct EmbedInNavigation: ViewModifier {
    var navigationTitle: LocalizedStringKey
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle(navigationTitle)
            .frame(minWidth: 300, idealWidth: 500, maxWidth: nil, minHeight: 340, idealHeight: 540, maxHeight: nil)
        #else
        NavigationView {
            content
                .navigationTitle(navigationTitle)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
