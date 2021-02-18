//
//  NavigationViewWrapper.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.02.2021.
//

import SwiftUI

struct NavigationViewWrapper<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        #if os(iOS)
        NavigationView {
            content()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        content()
        #endif
    }
}
