//
//  Enum.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

enum Digits: Int, CaseIterable, Identifiable {
    case six = 6
    case seven = 7
    case eight = 8

    var id: Int { rawValue }
}

extension Digits {
    var localized: LocalizedStringKey {
        switch self {
        case .six: return "6_digits"
        case .seven: return "7_digits"
        case .eight: return "8_digits"
        }
    }
}

enum Period: TimeInterval, CaseIterable, Identifiable {
    case thirty = 30
    case sixty = 60

    var id: TimeInterval { rawValue }
}

extension Period {
    var localized: LocalizedStringKey {
        switch self {
        case .thirty: return "30_seconds"
        case .sixty: return "60_seconds"
        }
    }
}

enum SheetState: String, Identifiable {
    case settings
    case addpassword

    var id: String { rawValue }
}
