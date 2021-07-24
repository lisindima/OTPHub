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
    var localized: LocalizedStringKey {
        switch self {
        case .six:
            return "6 digits"
        case .seven:
            return "7 digits"
        case .eight:
            return "8 digits"
        }
    }
}

enum Period: TimeInterval, CaseIterable, Identifiable {
    case thirty = 30
    case sixty = 60

    var id: TimeInterval { rawValue }
    var localized: LocalizedStringKey {
        switch self {
        case .thirty:
            return "30 seconds"
        case .sixty:
            return "60 seconds"
        }
    }
}
