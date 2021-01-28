//
//  NavigationStyle.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct NavigationStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .navigationViewStyle(StackNavigationViewStyle())
        #else
        content
        #endif
    }
}
