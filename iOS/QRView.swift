//
//  QRView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 06.02.2021.
//

import CodeScanner
import KeychainOTP
import SwiftUI

struct QRView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var label: String
    @Binding var issuer: String
    @Binding var secret: String
    @Binding var period: Period
    @Binding var digits: Digits
    @Binding var algorithm: OTPAlgorithm
    @Binding var typeAlgorithm: TypeAlgorithm
    @Binding var counter: UInt64

    private let simulatedData: String = "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=7&period=60"

    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: simulatedData
                ) { result in
                    switch result {
                    case let .success(code):
                        getURLComponents(code)
                        dismiss()
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
                    Text("Point the camera at the QR code")
                        .fontWeight(.bold)
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("Scan QR code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Text("Close")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }

    private func getURLComponents(_ string: String) {
        guard let url = URL(string: string) else { return }
        label = String(url.path.dropFirst())
        issuer = url["issuer"]
        secret = url["secret"]
        typeAlgorithm = url.host!.typeAlgorithmFromString()
        algorithm = url["algorithm"].algorithmFromString()
        digits = url["digits"].digitsFromString()
        period = url["period"].periodFromString()
        counter = url["counter"].counterFromString()
    }
}
