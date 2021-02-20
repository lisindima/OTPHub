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
            Section(footer: Text("section_footer_license")) {
                ForEach(licenseModel.sorted { $0.nameFramework < $1.nameFramework }, id: \.id) { license in
                    NavigationLink(destination: LicenseDetail(license: license)) {
                        Text(license.nameFramework)
                    }
                }
            }
        }
        .navigationTitle("navigation_title_license")
    }
}
