//
//  NavigationModifier.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct NavigationModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        NavigationView {
            content
        }
        #endif
    }
}
