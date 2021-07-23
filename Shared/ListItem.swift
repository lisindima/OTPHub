//
//  ListItem.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import KeychainOTP
import SwiftUI

struct ListItem: View {
    @Binding var account: Account

    @State private var otpString: String?
    @State private var progress: Float = 0.0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if account.generator.factor.getTypeAlgorithm == .hotp {
            hotp
        } else {
            totp
        }
    }

    var password: some View {
        VStack(alignment: .leading) {
            Text(account.label)
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.secondary)
            if let otpString = otpString {
                Text(otpString.separated())
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }

    var hotp: some View {
        Button(action: copyPasteboard) {
            HStack {
                password
                Spacer()
                Button(action: updateHOTP) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color(hex: account.color))
                }
                #if os(macOS)
                .buttonStyle(.plain)
                #endif
                .frame(width: 60)
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .onAppear(perform: generatePassword)
    }

    var totp: some View {
        Button(action: copyPasteboard) {
            HStack {
                password
                Spacer()
                ProgressView(value: progress, total: Float(account.generator.factor.getValuePeriod))
                    .progressViewStyle(.circular)
                    .accentColor(Color(hex: account.color))
                    .frame(width: 60)
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .onAppear(perform: generatePassword)
        .onReceive(timer) { _ in updateTOTP() }
    }
    
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
        otpString = account.generate(time: Date())
    }

    private func updateHOTP() {
        account = account.incrementCounter(keychain: AppStore.shared.keychain)
    }

    private func updateTOTP() {
        if progress < Float(account.generator.factor.getValuePeriod) {
            progress += 1
        } else if progress == Float(account.generator.factor.getValuePeriod) {
            progress = 0.0
            generatePassword()
        }
    }
}
