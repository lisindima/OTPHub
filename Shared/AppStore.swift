//
//  AppStore.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.02.2021.
//

import KeychainAccess
import OTP
import SwiftUI

class AppStore: ObservableObject {
    @Published var accounts = [Account]()
    
    static let shared = AppStore()
    
    let keychain = Keychain(service: "com.darkfox.otphub")
        .synchronizable(true)
    
    init() {
        accounts = try! loadAccountsFromKeychain()
    }
    
    func addAccount(_ account: Account) {
        do {
            try account.save(to: keychain)
        } catch {
            print(error)
        }
    }
    
    func removeAccount(account: Account) {
        do {
            try account.remove(from: keychain)
            guard let index = accounts.firstIndex(of: account) else { return }
            accounts.remove(at: index)
        } catch {
            print(error)
        }
    }
    
    func loadAccountsFromKeychain() throws -> [Account] {
        try Account.loadAll(from: keychain)
    }
}
