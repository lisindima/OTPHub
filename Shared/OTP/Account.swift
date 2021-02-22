//
//  Account.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.02.2021.
//

import Foundation
import CryptoKit
import KeychainAccess
import SwiftOTP

struct Account: Identifiable, Codable {
    var id = UUID()
    let label: String
    let issuer: String?
    let imageURL: URL?
    let color: String
    let generator: Generator
    
    var url: URL {
        let queryItemImageURL = URLQueryItem(name: "image", value: imageURL?.absoluteString)
        // otpauth://TYPE/ISSUER:LABEL?PARAMETERS
        let issuerString = issuer?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        guard let labelString = label.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              var components = URLComponents(string: "otpauth://\(Factor.getHostName)/\(issuerString)\(issuerString.isEmpty ? "" : ":")\(labelString)") else {
            fatalError("Error encoding URL")
        }
        var queryItems = [queryItemImageURL] + generator.urlQueryItems
        // remove query items with no value (optional parameters)
        queryItems = queryItems.filter { $0.value != nil }
        components.queryItems = queryItems
        return components.url!
    }
    
    init(label: String, issuer: String? = nil, imageURL: URL? = nil, color: String, generator: Generator) {
        self.label = label
        self.issuer = issuer
        self.imageURL = imageURL
        self.color = color
        self.generator = generator
    }
    
    init(from url: URL) throws {
        // otpauth://TYPE/LABEL?PARAMETERS
        let components = url.pathComponents.dropFirst().first?.split(separator: ":")
        
        guard let labelComponent = components?.last else {
            throw DeserializationError.invalidURLScheme
        }
        let label = String(labelComponent)

        var issuer: String?
        if let issuerComponent = components?.dropLast().last {
            issuer = String(issuerComponent)
        }
        
        var imageURL: URL?
        let imageURLString = url["image"]
        imageURL = URL(string: imageURLString)
        
        let generator = try Generator(from: url)
        
        self.init(label: label, issuer: issuer, imageURL: imageURL, color: "", generator: generator)
    }
    
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
        try keychain
            .label(label)
            .comment("OTP access token")
            .set(url.absoluteString, key: id.uuidString)
    }
    
    func loadAll(from keychain: Keychain) throws -> [Account] {
        let items = keychain.allKeys()
        let accounts = try items.compactMap { key throws -> Account? in
            guard let urlString = try keychain.get(key), let url = URL(string: urlString) else { return nil }
            return try Account(from: url)
        }
        return accounts
    }
}

struct Generator: Codable {
    let algorithm: PasswordAlgorithm
    let secret: Data
    let factor: Factor
    let digits: Int
    
    var urlQueryItems: [URLQueryItem] {
        let items: [URLQueryItem] = [
            URLQueryItem(name: "secret", value: secret.base32EncodedString.lowercased()),
            URLQueryItem(name: "algorithm", value: algorithm.rawValue),
            //Factor.factor,
            URLQueryItem(name: "digits", value: String(digits)),
        ]
        return items
    }
    
    init(algorithm: PasswordAlgorithm, secret: Data, factor: Factor, digits: Int) {
        self.algorithm = algorithm
        self.secret = secret
        self.factor = factor
        self.digits = digits
    }
    
    init(from url: URL) throws {
        guard url.scheme == kOTPAuthScheme else {
            throw DeserializationError.invalidURLScheme
        }

        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        let factor: Factor
        switch url.host {
        case .some(kFactorCounterKey):
            let counterValue = try queryItems.value(for: kQueryCounterKey).map(parseCounterValue) ?? 0
            factor = .counter(counterValue)
        case .some(kFactorTimerKey):
            let period = try queryItems.value(for: kQueryPeriodKey).map(parseTimerPeriod) ?? 30
            factor = .timer(period: period)
        case let .some(rawValue):
            throw DeserializationError.invalidFactor(rawValue)
        case .none:
            throw DeserializationError.missingFactor
        }

        let algorithm = try queryItems.value(for: kQueryAlgorithmKey).map(algorithmFromString) ?? .sha1
        let digits = try queryItems.value(for: kQueryDigitsKey).map(parseDigits) ?? 6
        guard let secret = try queryItems.value(for: kQuerySecretKey).map(parseSecret) else {
            throw DeserializationError.missingSecret
        }
        self.init(algorithm: algorithm, secret: secret, factor: factor, digits: digits)
    }
}

private func algorithmFromString(_ string: String) -> PasswordAlgorithm {
    switch string {
    case kAlgorithmSHA1:
        return .sha1
    case kAlgorithmSHA256:
        return .sha256
    case kAlgorithmSHA512:
        return .sha512
    default:
        return .sha1
    }
}

private let kOTPAuthScheme = "otpauth"
private let kQueryAlgorithmKey = "algorithm"
private let kQuerySecretKey = "secret"
private let kQueryCounterKey = "counter"
private let kQueryDigitsKey = "digits"
private let kQueryPeriodKey = "period"
private let kQueryIssuerKey = "issuer"

private let kFactorCounterKey = "hotp"
private let kFactorTimerKey = "totp"

private let kAlgorithmSHA1   = "SHA1"
private let kAlgorithmSHA256 = "SHA256"
private let kAlgorithmSHA512 = "SHA512"

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
    
    fileprivate func getHostName() -> String {
        switch self {
        case .timer(_):
            return "totp"
        case .counter(_):
            return "hotp"
        }
    }
    
    var factor: URLQueryItem {
        switch self {
        case .timer(let period):
            return URLQueryItem(name: "period", value: String(Int(period)))
        case .counter(let counter):
            return URLQueryItem(name: "counter", value: String(counter))
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

private func parseCounterValue(_ rawValue: String) throws -> UInt64 {
    guard let counterValue = UInt64(rawValue) else {
        return 0
    }
    return counterValue
}

private func parseTimerPeriod(_ rawValue: String) throws -> TimeInterval {
    guard let period = TimeInterval(rawValue) else {
        return 30
    }
    return period
}

private func parseSecret(_ rawValue: String) throws -> Data {
    let secret = base32DecodeToData(rawValue)
    return secret!
}

private func parseDigits(_ rawValue: String) throws -> Int {
    guard let digits = Int(rawValue) else {
        return 6
    }
    return digits
}

private func shortName(byTrimming issuer: String, from fullName: String) -> String {
    if !issuer.isEmpty {
        let prefix = issuer + ":"
        if fullName.hasPrefix(prefix), let prefixRange = fullName.range(of: prefix) {
            let substringAfterSeparator = fullName[prefixRange.upperBound...]
            return substringAfterSeparator.trimmingCharacters(in: CharacterSet.whitespaces)
        }
    }
    return String(fullName)
}

extension Array where Element == URLQueryItem {
    func value(for name: String) throws -> String? {
        let matchingQueryItems = self.filter({
            $0.name == name
        })
        return matchingQueryItems.first?.value
    }
}

internal enum SerializationError: Swift.Error {
    case urlGenerationFailure
}

internal enum DeserializationError: Swift.Error {
    case invalidURLScheme
    case duplicateQueryItem(String)
    case missingFactor
    case invalidFactor(String)
    case invalidCounterValue(String)
    case invalidTimerPeriod(String)
    case missingSecret
    case invalidSecret(String)
    case invalidAlgorithm(String)
    case invalidDigits(String)
}
