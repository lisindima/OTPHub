//
//  CustomButton.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct CustomButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.accentColor)
        .cornerRadius(8)
        .shadow(radius: 6)
        .padding()
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
