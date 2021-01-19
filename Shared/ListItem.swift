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
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    private func generatePassword() {
        var algorithm: OTPAlgorithm = .sha1
        if item.passwordAlgorithm == "SHA1" {
            algorithm = .sha1
        } else if item.passwordAlgorithm == "SHA256" {
            algorithm = .sha256
        } else if item.passwordAlgorithm == "SHA512" {
            algorithm = .sha512
        }
        
        guard let secret = item.passwordSecret else { return }
        guard let data = base32DecodeToData(secret) else { return }
        let totp = TOTP(secret: data, digits: Int(item.sizePassword), timeInterval: Int(item.updateTime), algorithm: algorithm)
        otpString = totp!.generate(time: Date())!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.passwordName!)
                .font(.footnote)
            Text(otpString)
                .font(.title)
                .fontWeight(.bold)
                .animation(.interactiveSpring())
        }
        .padding(.vertical, 6)
        .onReceive(timer) { _ in
            generatePassword()
        }
        .onAppear(perform: generatePassword)
    }
}
