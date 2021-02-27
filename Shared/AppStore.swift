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

    func loadAccountsFromKeychain() throws -> [Account] {
        try Account.loadAll(from: keychain)
    }

    func importAccountInKeychain(_ url: URL?) {
        guard let url = url else { return }
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        let account = try! decoder.decode([Account].self, from: data)
        print(account)
    }
}
