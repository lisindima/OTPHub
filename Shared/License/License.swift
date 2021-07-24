//
//  License.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 20.02.2021.
//

import SwiftUI

struct License: View {
    let licenseModel = Bundle.main.decode("license.json")

    var body: some View {
        Form {
            Section(footer: Text("Listed here are the open source libraries and frameworks that are used in this application.")) {
                ForEach(licenseModel.sorted { $0.nameFramework < $1.nameFramework }, id: \.id) { license in
                    NavigationLink(destination: LicenseDetail(license: license)) {
                        Text(license.nameFramework)
                    }
                }
            }
        }
        .navigationTitle("License")
    }
}
