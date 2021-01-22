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
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    
    var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    var black: Color {
        #if os(iOS)
        return Color(UIColor.black.withAlphaComponent(0.08))
        #else
        return Color(NSColor.black.withAlphaComponent(0.08))
        #endif
    }
    
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
        .background(colorScheme == .dark ? secondarySystemBackground : systemBackground)
        .cornerRadius(28)
        .shadow(color: black, radius: 8, x: 0, y: 4)
    }
}
