//
//  ViewModifier.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct ListStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .listStyle(InsetGroupedListStyle())
        #else
        content
        #endif
    }
}
