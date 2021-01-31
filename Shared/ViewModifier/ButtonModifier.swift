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
        #if os(iOS)
        Button(action: action) {
            content
        }
        #else
        content
            .onTapGesture(perform: action)
        #endif
    }
}
