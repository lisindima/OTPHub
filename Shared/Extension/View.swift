//
//  View.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

extension View {
    func button(action: @escaping () -> Void) -> some View {
        modifier(ButtonModifier(action: action))
    }
}

extension View {
    func empedInNavigation(title: LocalizedStringKey) -> some View {
        modifier(EmbedInNavigation(title: title))
    }
}

extension View {
    func colorPickerMac() -> some View {
        modifier(ColorPickerMac())
    }
}

extension View {
    func customPickerStyle() -> some View {
        modifier(CustomPickerStyle())
    }
}

extension View {
    @ViewBuilder
    func toast(isPresented: Binding<Bool>) -> some View {
        #if !os(watchOS)
        modifier(ToastModifier(isPresented: isPresented))
        #endif
    }
}

