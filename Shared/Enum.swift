//
//  Enum.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

enum SizePassword: Int32, CaseIterable, Identifiable {
    case sixDigit = 6
    case sevenDigit = 7
    case eightDigit = 8

    var id: Int32 { rawValue }
}

extension SizePassword {
    var localized: LocalizedStringKey {
        switch self {
        case .sixDigit: return "6_digits"
        case .sevenDigit: return "7_digits"
        case .eightDigit: return "8_digits"
        }
    }
}

enum UpdateTime: Int32, CaseIterable, Identifiable {
    case thirtySeconds = 30
    case sixtySeconds = 60

    var id: Int32 { rawValue }
}

extension UpdateTime {
    var localized: LocalizedStringKey {
        switch self {
        case .thirtySeconds: return "30_seconds"
        case .sixtySeconds: return "60_seconds"
        }
    }
}

enum PasswordAlgorithm: String, CaseIterable, Identifiable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"
    
    var id: String { rawValue }
}

enum TypeAlgorithm: String, CaseIterable, Identifiable {
    case totp = "TOTP"
    case hotp = "HOTP"
    
    var id: String { rawValue }
}
