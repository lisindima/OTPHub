//
//  ToastView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 20.01.2021.
//

import SwiftUI

struct ToastView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var image: String?
    var title: String
    var subtitle: String?
    
    var body: some View {
        HStack(spacing: 16) {
            if let image = image {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            VStack(alignment: .center) {
                Text(title)
                    .lineLimit(1)
                    .font(.headline)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(image == nil ? .horizontal : .trailing)
        }
        .padding(.horizontal)
        .frame(height: 56)
        .background(Color(colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground))
        .cornerRadius(28)
        .shadow(color: Color(UIColor.black.withAlphaComponent(0.08)), radius: 8, x: 0, y: 4)
    }
}
