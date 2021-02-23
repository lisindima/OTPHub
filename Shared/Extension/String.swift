//
//  String.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.01.2021.
//

import Foundation

extension String {
    func separated(separator: String = " ", stride: Int = 2) -> String {
        enumerated().map { $0.isMultiple(of: stride) && ($0 != 0) ? "\(separator)\($1)" : String($1) }.joined()
    }
    
    func digitsFromString() -> Digits {
        switch self {
        case "6":
            return .six
        case "7":
            return .seven
        case "8":
            return .eight
        default:
            return .six
        }
    }
    
    func periodFromString() -> Period {
        switch self {
        case "30":
            return .thirty
        case "60":
            return .sixty
        default:
            return .thirty
        }
    }
    
    func counterFromString() -> UInt64 {
        UInt64(self) ?? 0
    }
}
