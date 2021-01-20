//
//  PasteboardIndicator.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 20.01.2021.
//

import SwiftUI

struct PasteboardIndicator: ViewModifier {
    @Binding var isPresented: Bool
    
    func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPresented = false
        }
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Код скопирован")
                            .fontWeight(.bold)
                            .font(.system(.body, design: .rounded))
                    }
                    .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.purple)
                .cornerRadius(8)
                .zIndex(1)
                .padding(.horizontal)
                .animation(.easeInOut)
                .transition(
                    AnyTransition
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                )
                .onAppear(perform: dismiss)
            }
            content
        }
    }
}

extension View {
    func pasteboardIndicator(isPresented: Binding<Bool>) -> some View {
        modifier(PasteboardIndicator(isPresented: isPresented))
    }
}
