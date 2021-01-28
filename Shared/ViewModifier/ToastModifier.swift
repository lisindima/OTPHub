//
//  ToastModifier.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            ToastView(title: "toast_title_copy")
                .offset(y: isPresented ? 0 : -128)
                .zIndex(1)
                .animation(.spring())
                .onChange(of: isPresented) { _ in
                    if isPresented {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isPresented = false
                        }
                    }
                }
            content
        }
    }
}
