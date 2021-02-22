//
//  String.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.01.2021.
//

import Foundation
import SwiftOTP

extension String {
    func separated(separator: String = " ", stride: Int = 2) -> String {
        enumerated().map { $0.isMultiple(of: stride) && ($0 != 0) ? "\(separator)\($1)" : String($1) }.joined()
    }
    
    func algorithmFromString() -> OTPAlgorithm {
        switch self {
        case "SHA1":
            return .sha1
        case "SHA256":
            return .sha256
        case "SHA512":
            return .sha512
        default:
            return .sha1
        }
    }
    
    func passwordAlgorithmFromString() -> PasswordAlgorithm {
        switch self {
        case "SHA1":
            return .sha1
        case "SHA256":
            return .sha256
        case "SHA512":
            return .sha512
        default:
            return .sha1
        }
    }
    
    func digitFromString() -> SizePassword {
        switch self {
        case "6":
            return .sixDigit
        case "7":
            return .sevenDigit
        case "8":
            return .eightDigit
        default:
            return .sixDigit
        }
    }
    
    func typeAlgorithmFromString() -> TypeAlgorithm {
        switch self {
        case "totp":
            return .totp
        case "hotp":
            return .hotp
        default:
            return .totp
        }
    }
    
    func updateTimeFromString() -> UpdateTime {
        switch self {
        case "30":
            return .thirtySeconds
        case "60":
            return .sixtySeconds
        default:
            return .thirtySeconds
        }
    }
    
    func counterFromString() -> UInt64 {
        UInt64(self) ?? 1
    }
}
