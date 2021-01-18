//
//  Enum.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import Foundation

enum SizePassword: Int, CaseIterable, Identifiable {
    case sixDigit = 6
    case sevenDigit = 7
    case eightDigit = 8

    var id: Int { self.rawValue }
}

enum UpdateTime: Int, CaseIterable, Identifiable {
    case thirtySeconds = 30
    case sixtySeconds = 60

    var id: Int { self.rawValue }
}
