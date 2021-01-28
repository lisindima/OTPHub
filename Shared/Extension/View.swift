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
    func navigationView() -> some View {
        modifier(NavigationModifier())
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

#if !os(watchOS)
extension View {
    func toast(isPresented: Binding<Bool>) -> some View {
        modifier(ToastModifier(isPresented: isPresented))
    }
}
#endif

