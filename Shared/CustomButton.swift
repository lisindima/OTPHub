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
        #if os(iOS)
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
        #else
        Button(action: action) {
            Text(title)
        }
        #endif
    }
}
