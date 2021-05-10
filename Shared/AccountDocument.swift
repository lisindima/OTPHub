//
//  AccountDocument.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 27.02.2021.
//

import KeychainOTP
import SwiftUI
import UniformTypeIdentifiers

struct AccountDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.init("com.darkfox.otphub.backup")!] }

    var account: [Account]

    init(account: [Account]) {
        self.account = account
    }

    init(configuration: ReadConfiguration) throws {
        let decoder = JSONDecoder()
        guard let data = configuration.file.regularFileContents, let account = try? decoder.decode([Account].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.account = account
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(account)
        return FileWrapper(regularFileWithContents: encoded)
    }
}
