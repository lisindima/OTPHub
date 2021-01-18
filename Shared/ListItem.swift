//
//  ListItem.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftOTP
import SwiftUI

struct ListItem: View {
    @State private var otpString: String = ""
    
    var item: Item
    
    private func generatePassword() {
        guard let data = base32DecodeToData("JBSWY3DPEHPK3PXP") else { return }
        let totp = TOTP(secret: data, digits: Int(item.sizePassword), timeInterval: Int(item.updateTime), algorithm: .sha1)
        otpString = totp!.generate(time: Date())!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.passwordName!)
                .font(.footnote)
            Text(otpString)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.vertical, 6)
        .onAppear(perform: generatePassword)
    }
}
