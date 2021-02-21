//
//  AppStore.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.02.2021.
//

import SwiftUI
import KeychainAccess

class AppStore: ObservableObject {
    static let shared = AppStore()
    
    let keychain = Keychain(service: "com.darkfox.otphub")
        .synchronizable(true)
    
    func addAccount(_ account: Account) {
        do {
            try account.save(to: keychain)
        } catch let error {
            print(error)
        }
    }
}
