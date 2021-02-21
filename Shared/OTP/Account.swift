//
//  Account.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.02.2021.
//

import Foundation
import CryptoKit
import KeychainAccess

struct Account: Identifiable, Codable {
    var id = UUID()
    let label: String
    let issuer: String?
    let color: String
    let imageURL: URL?
    let generator: Generator
    
    func generate(time: Date) -> String? {
        let counter = try! generator.factor.counterValue(at: time)
        return generateOTP(secret: generator.secret, algorithm: generator.algorithm, counter: counter, digits: generator.digits)
    }
    
    private func generateOTP(secret: Data, algorithm: PasswordAlgorithm = .sha1, counter: UInt64, digits: Int = 6) -> String? {
        // HMAC message data from counter as big endian
        let counterMessage = counter.bigEndian.data

        // HMAC hash counter data with secret key
        var hmac = Data()

        switch algorithm {
        case .sha1:
            hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
        case .sha256:
            hmac = Data(HMAC<SHA256>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
        case .sha512:
            hmac = Data(HMAC<SHA512>.authenticationCode(for: counterMessage, using: SymmetricKey.init(data: secret)))
        }

        
        // Get last 4 bits of hash as offset
        let offset = Int((hmac.last ?? 0x00) & 0x0f)
        
        // Get 4 bytes from the hash from [offset] to [offset + 3]
        let truncatedHMAC = Array(hmac[offset...offset + 3])
        
        // Convert byte array of the truncated hash to data
        let data =  Data(truncatedHMAC)
        
        // Convert data to UInt32
        var number = UInt32(strtoul(data.bytes.toHexString(), nil, 16))
        
        // Mask most significant bit
        number &= 0x7fffffff
        
        // Modulo number by 10^(digits)
        number = number % UInt32(pow(10, Float(digits)))

        // Convert int to string
        let strNum = String(number)
        
        // Return string if adding leading zeros is not required
        if strNum.count == digits {
            return strNum
        }
        
        // Add zeros to start of string if not present and return
        let prefixedZeros = String(repeatElement("0", count: (digits - strNum.count)))
        return (prefixedZeros + strNum)
    }
    
    func save(to keychain: Keychain) throws {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            try keychain
                .label(label)
                .comment("OTP access token")
                .set(encoded, key: id.uuidString)
        }
    }
}

struct Generator: Codable {
    let algorithm: PasswordAlgorithm
    let secret: Data
    let factor: Factor
    let digits: Int
}

enum Factor {
    case counter(UInt64)
    case timer(period: TimeInterval)
    
    fileprivate func counterValue(at time: Date) throws -> UInt64 {
        switch self {
        case .counter(let counter):
            return counter
        case .timer(let period):
            let timeSinceEpoch = time.timeIntervalSince1970
//                try Generator.validateTime(timeSinceEpoch)
//                try Generator.validatePeriod(period)
            return UInt64(timeSinceEpoch / period)
        }
    }
}

extension Factor {
    enum CodingKeys: String, CodingKey {
        case counter, timer
    }
}

extension Factor: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .counter(let counter):
            try container.encode(counter, forKey: .counter)
        case .timer(let period):
            try container.encode(period, forKey: .timer)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .counter:
            let counter = try container.decode(UInt64.self, forKey: .counter)
            self = .counter(counter)
        case .timer:
            let timer = try container.decode(TimeInterval.self, forKey: .timer)
            self = .timer(period: timer)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

// УЖЕ РЕАЛИЗОВАНО В SwiftOTP Скопировал сюда ради исправления ошибки!!!!
extension UInt64 {
    /// Data from UInt64
    var data: Data {
        var int = self
        let intData = Data(bytes: &int, count: MemoryLayout.size(ofValue: self))
        return intData
    }
}
