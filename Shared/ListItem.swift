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
    @State private var progress: Float = 0.0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var width: CGFloat {
        #if os(watchOS)
        return CGFloat(40)
        #else
        return CGFloat(60)
        #endif
    }
    
    func copyPasteboard() {
        #if os(macOS)
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(otpString, forType: .string)
        #elseif os(iOS)
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
        
        guard let data = item.passwordSecret else { return }
        guard let secret = base32DecodeToData(data) else { return }
        
        let digits = Int(item.sizePassword)
        let timeInterval = Int(item.updateTime)
        
        if let totp = TOTP(
            secret: secret,
            digits: digits,
            timeInterval: timeInterval,
            algorithm: algorithm
        ) {
            otpString = totp.generate(time: Date())!
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.passwordName ?? "")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.secondary)
                #if os(watchOS)
                Text(otpString.separated())
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                #else
                Text(otpString.separated())
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .animation(.interactiveSpring())
                #endif
            }
            Spacer()
            ProgressView(value: progress, total: Float(Int(item.updateTime)))
                .frame(width: width)
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
