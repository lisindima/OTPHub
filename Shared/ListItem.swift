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
    
    @State private var otpString: String?
    @State private var progress: Float = 0.0
    
    @SceneStorage("counter") private var counter: Int = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func copyPasteboard() {
        if let otpString = otpString {
            #if os(macOS)
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(otpString, forType: .string)
            #else
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            UIPasteboard.general.string = otpString
            #endif
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
    var body: some View {
        if item.typeAlgorithm == "HOTP" {
            hotp
        } else {
            totp
        }
    }
    
    var password: some View {
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
            }
        }
    }
    
    var hotp: some View {
        HStack {
            password
            Spacer()
            Button(action: generatePassword) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 60)
        }
        .button(action: copyPasteboard)
        .onAppear(perform: generatePassword)
    }
    
    var totp: some View {
        HStack {
            password
            Spacer()
            if let passwordColor = item.passwordColor {
                ProgressView(value: progress, total: item.updateTime.toFloat())
                    .accentColor(Color(hex: passwordColor))
                    .frame(width: 60)
            }
        }
        .button(action: copyPasteboard)
        .onAppear(perform: generatePassword)
        .onReceive(timer) { _ in
            if progress < item.updateTime.toFloat() {
                progress += 1
            } else if progress == item.updateTime.toFloat() {
                progress = 0.0
                generatePassword()
            }
        }
    }
}
