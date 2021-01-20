//
//  CustomButton.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct CustomButton: View {
    var title: LocalizedStringKey
    var action: () -> Void
    
    init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
        }
        .background(Color.accentColor)
        .cornerRadius(8)
    }
}

struct ButtonModifier: ViewModifier {
    var action: () -> Void
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        Button(action: action) {
            content
        }
        #endif
    }
}

extension View {
    func button(action: @escaping () -> Void) -> some View {
        modifier(ButtonModifier(action: action))
    }
}
