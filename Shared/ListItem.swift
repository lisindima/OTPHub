//
//  ListItem.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftOTP
import SwiftUI

struct ListItem: View {
    @Environment(\.managedObjectContext) private var moc
    
    @State private var otpString: String?
    @State private var progress: Float = 0.0
    
    var item: Item
    
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
    
    private func saveCounter() {
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func generatePassword() {
        var algorithm: OTPAlgorithm = .sha1
        algorithm = item.passwordAlgorithm!.algorithmFromString()
        
        guard let data = item.passwordSecret else { return }
        guard let secret = base32DecodeToData(data) else { return }
        
        let digits = item.sizePassword.toInt()
        let timeInterval = item.updateTime.toInt()
        
        if item.typeAlgorithm == "HOTP" {
            item.passwordCounter += 1
            if let hotp = HOTP(
                secret: secret,
                digits: digits,
                algorithm: algorithm
            ) {
                otpString = hotp.generate(counter: UInt64(item.passwordCounter))
            }
            saveCounter()
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
        Button(action: copyPasteboard) {
            HStack {
                password
                Spacer()
                Button(action: generatePassword) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .imageScale(.large)
                }
                .macOS { $0.buttonStyle(PlainButtonStyle()) }
                .frame(width: 60)
            }
        }
        .macOS { $0.buttonStyle(PlainButtonStyle()) }
        .onAppear(perform: generatePassword)
    }
    
    var totp: some View {
        Button(action: copyPasteboard) {
            HStack {
                password
                Spacer()
                if let passwordColor = item.passwordColor {
                    ProgressView(value: progress, total: item.updateTime.toFloat())
                        .macOS { $0.progressViewStyle(CircularProgressViewStyle()) }
                        .accentColor(Color(hex: passwordColor))
                        .frame(width: 60)
                }
            }
        }
        .macOS { $0.buttonStyle(PlainButtonStyle()) }
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
