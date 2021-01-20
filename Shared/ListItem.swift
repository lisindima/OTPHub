//
//  ListItem.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftOTP
import SwiftUI

struct ListItem: View {
    var item: Item
    
    @Binding var showIndicator: Bool
    @State private var otpString: String = ""
    
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    func copyPasteboard() {
        #if os(macOS)
        NSPasteboard.general.setString(otpString, forType: .string)
        #else
        UIPasteboard.general.string = otpString
        #endif
        showIndicator = true
    }
    
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
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.secondary)
            Text(otpString)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .animation(.interactiveSpring())
        }
        .button(action: copyPasteboard)
        .onAppear(perform: generatePassword)
        .onReceive(timer) { _ in
            generatePassword()
        }
    }
}
