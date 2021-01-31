//
//  CustomTextField.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 31.01.2021.
//

import SwiftUI

struct CustomTextField: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
        #else
        content
        #endif
    }
}
