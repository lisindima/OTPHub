//
//  LicenseModel.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 20.02.2021.
//

import Foundation

struct LicenseModel: Identifiable, Codable {
    let id: Int
    let urlFramework: URL
    let nameFramework, textLicenseFramework: String
}
