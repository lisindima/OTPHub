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
    
    @State private var showIndicator: Bool = false
    @State private var otpString: String?
    @State private var progress: Float = 0.0
    
    @AppStorage("counter") private var counter: Int = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func copyPasteboard() {
        if let otpString = otpString {
            #if os(macOS)
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(otpString, forType: .string)
            #else
            UIPasteboard.general.string = otpString
            #endif
            withAnimation(.spring()) {
                showIndicator = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showIndicator = false
                }
            }
        }
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
        
        guard let data = item.passwordSecret else { return }
        guard let secret = base32DecodeToData(data) else { return }
        
        let digits = Int(item.sizePassword)
        let timeInterval = Int(item.updateTime)
        
        if item.typeAlgorithm == "HOTP" {
            counter += 1
            if let hotp = HOTP(
                secret: secret,
                digits: digits,
                algorithm: algorithm
            ) {
                otpString = hotp.generate(counter: UInt64(counter))
            }
        } else {
            if let totp = TOTP(
                secret: secret,
                digits: digits,
                timeInterval: timeInterval,
                algorithm: algorithm
            ) {
                otpString = totp.generate(time: Date())
            }
        }
    }
    
    @ViewBuilder
    private func progressView(_ passwordColor: String) -> some View {
        if showIndicator {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(.large)
                .foregroundColor(Color(hex: passwordColor))
                .frame(width: 60)
        } else {
            ProgressView(value: progress, total: Float(Int(item.updateTime)))
                .accentColor(Color(hex: passwordColor))
                .frame(width: 60)
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let passwordName = item.passwordName {
                    Text(passwordName)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.secondary)
                }
                if let otpString = otpString {
                    Text(otpString.separated())
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .animation(.interactiveSpring())
                }
            }
            Spacer()
            if let passwordColor = item.passwordColor {
                progressView(passwordColor)
            }
        }
        .button(action: copyPasteboard)
        .onAppear(perform: generatePassword)
        .onReceive(timer) { _ in
            if progress < Float(Int(item.updateTime)) {
                progress += 1
            } else if progress == Float(Int(item.updateTime)) {
                progress = 0.0
                generatePassword()
            }
        }
    }
}
