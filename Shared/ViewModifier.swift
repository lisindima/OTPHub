//
//  ViewModifier.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct ListStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .listStyle(InsetGroupedListStyle())
        #else
        content
        #endif
    }
}

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

extension View {
    func button(action: @escaping () -> Void) -> some View {
        modifier(ButtonModifier(action: action))
    }
}

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

extension View {
    func navigationView() -> some View {
        modifier(NavigationModifier())
    }
}

struct ColorPickerMac: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .labelsHidden()
            .frame(height: 50)
        #else
        content
        #endif
    }
}

extension View {
    func colorPickerMac() -> some View {
        modifier(ColorPickerMac())
    }
}
