//
//  ListStyle.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import SwiftUI

struct ListStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .listStyle(InsetGroupedListStyle())
            .environment(\.defaultMinListRowHeight, 70)
        #else
        content
            .environment(\.defaultMinListRowHeight, 70)
        #endif
    }
}
