//
//  Alert.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 26.02.2021.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: LocalizedStringKey = "alert_error_title"
    var message: LocalizedStringKey
    var action: (() -> Void)? = {}
}

struct CustomAlert: ViewModifier {
    @Binding var item: AlertItem?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $item) { item in
                alert(title: item.title, message: item.message, action: item.action)
            }
    }
}

extension ViewModifier {
    func alert(title: LocalizedStringKey, message: LocalizedStringKey, action: (() -> Void)? = {}) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .cancel(Text("Закрыть"), action: action)
        )
    }
}

extension View {
    func customAlert(item: Binding<AlertItem?>) -> some View {
        modifier(CustomAlert(item: item))
    }
}
