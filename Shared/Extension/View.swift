//
//  View.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

extension View {
    func empedInNavigation(_ navigationTitle: LocalizedStringKey) -> some View {
        self.modifier(EmbedInNavigation(navigationTitle: navigationTitle))
    }
    
    func customListStyle() -> some View {
        self.modifier(ListStyle())
    }
    
    func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        modifier(self)
        #else
        self
        #endif
    }
}
