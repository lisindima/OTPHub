//
//  CustomLabel.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 04.02.2021.
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
        configuration.icon
        #else
        configuration.title
        #endif
    }
}
