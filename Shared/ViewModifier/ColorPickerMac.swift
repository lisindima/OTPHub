//
//  ColorPickerMac.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

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
