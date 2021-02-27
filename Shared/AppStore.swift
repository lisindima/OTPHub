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
        accounts = Account.loadAll(from: keychain)
    }

    func addAccount(_ account: Account) {
        do {
            try account.save(to: keychain)
            accounts.append(account)
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

    func importAccountInKeychain(_ url: URL?) {
        guard let url = url else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        
        let decoder = JSONDecoder()
        guard let accounts = try? decoder.decode([Account].self, from: data) else { return }
        
        try? keychain.removeAll()
        
        for account in accounts {
            addAccount(account)
        }
    }
}
