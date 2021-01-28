//
//  ButtonModifier.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    var action: () -> Void
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #elseif os(iOS)
        Button(action: action) {
            content
        }
        #elseif os(macOS)
        content
            .onTapGesture(perform: action)
        #endif
    }
}
