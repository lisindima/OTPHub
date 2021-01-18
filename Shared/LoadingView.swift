//
//  LoadingView.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    var items: FetchedResults<Item>
    var title: String = ""
    var subTitle: String = ""
    var content: (_ notes: FetchedResults<Item>) -> Content
    
    init(_ items: FetchedResults<Item>, title: String, subTitle: String, content: @escaping (_ notes: FetchedResults<Item>) -> Content) {
        self.items = items
        self.title = title
        self.subTitle = subTitle
        self.content = content
    }
    
    var body: some View {
        if items.isEmpty {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 6)
            Text(subTitle)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
        } else {
            content(items)
        }
    }
}
