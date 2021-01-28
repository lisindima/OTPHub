//
//  CustomPickerStyle.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct CustomPickerStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
            .pickerStyle(WheelPickerStyle())
        #else
        content
            .pickerStyle(SegmentedPickerStyle())
        #endif
    }
}
