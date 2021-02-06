//
//  QRView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 06.02.2021.
//

import CodeScanner
import SwiftUI

struct QRView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var passwordName: String
    @Binding var passwordSecret: String
    @Binding var updateTime: UpdateTime
    @Binding var sizePassword: SizePassword
    @Binding var passwordAlgorithm: PasswordAlgorithm
    @Binding var typeAlgorithm: TypeAlgorithm
    
    private let simulatedData: String = "otpauth://totp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA====&algorithm=SHA256&digits=8"
    
    private func getURLComponents(_ url: URL) {
        passwordSecret = url["secret"]
        let algorithm = url["algorithm"]
        if algorithm == "SHA1" {
            passwordAlgorithm = .sha1
        } else if algorithm == "SHA256" {
            passwordAlgorithm = .sha256
        } else if algorithm == "SHA512" {
            passwordAlgorithm = .sha512
        }
        let digit = url["digits"]
        if digit == "6" {
            sizePassword = .sixDigit
        } else if digit == "7" {
            sizePassword = .sevenDigit
        } else if digit == "8" {
            sizePassword = .eightDigit
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: simulatedData
                ) { result in
                    switch result {
                    case let .success(code):
                        getURLComponents(URL(string: code)!)
                        presentationMode.wrappedValue.dismiss()
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                VStack {
                    Spacer()
                    Image(systemName: "viewfinder")
                        .resizable()
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .padding(.top)
                        .frame(width: 300, height: 300)
                    Spacer()
                    Text("bottom_title_scan_qr")
                        .fontWeight(.bold)
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("navigation_title_scan_qr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}
