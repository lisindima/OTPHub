//
//  LicenseDetail.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 20.02.2021.
//

import SwiftUI

struct LicenseDetail: View {
    var license: LicenseModel

    var body: some View {
        ScrollView {
            Text(license.textLicenseFramework)
                .font(.system(size: 14, design: .monospaced))
                .padding()
        }
        .navigationTitle(license.nameFramework)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Link(destination: license.urlFramework) {
                    Label("Open link", systemImage: "safari")
                }
            }
        }
    }
}
