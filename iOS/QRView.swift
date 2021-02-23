//
//  QRView.swift
//  OTPHub (iOS)
//
//  Created by Дмитрий Лисин on 06.02.2021.
//

import CodeScanner
import OTP
import SwiftUI

struct QRView: View {
    @Environment(\.presentationMode) private var presentationMode

    @Binding var label: String
    @Binding var secret: String
    @Binding var period: Period
    @Binding var digits: Digits
    @Binding var algorithm: OTPAlgorithm
    @Binding var typeAlgorithm: TypeAlgorithm
    @Binding var counter: UInt64

    private let simulatedData: String = "otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA256&digits=7&period=60"

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }

    private func getURLComponents(_ string: String) {
        guard let url = URL(string: string) else { return }
        label = String(url.path.dropFirst())
        typeAlgorithm = url.host!.typeAlgorithmFromString()
        secret = url["secret"]
        algorithm = url["algorithm"].algorithmFromString()
        digits = url["digits"].digitsFromString()
        period = url["period"].periodFromString()
        counter = url["counter"].counterFromString()
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
                        getURLComponents(code)
                        dismissView()
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
                    Button(action: dismissView) {
                        Image(systemName: "xmark")
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}
