//
//  CustomButtonStyle.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color = .accentColor
    var labelColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(labelColor)
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(radius: 6)
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
