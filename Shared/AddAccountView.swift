//
//  AddAccountView.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import KeychainOTP
import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var appStore: AppStore

    @State private var label: String = ""
    @State private var issuer: String = ""
    @State private var secret: String = ""
    @State private var image: URL?
    @State private var period: Period = .thirty
    @State private var digits: Digits = .six
    @State private var algorithm: OTPAlgorithm = .sha1
    @State private var typeAlgorithm: TypeAlgorithm = .totp
    @State private var counter: UInt64 = 0
    @State private var color: Color = .black
    @State private var isShowQRView: Bool = false
    @State private var alertItem: AlertItem?

    var body: some View {
        NavigationViewWrapper {
            VStack {
                Form {
                    Section {
                        TextField("Label", text: $label)
                        TextField("Secret", text: $secret)
                            .disableAutocorrection(true)
                    } header: {
                        Text("Basic information")
                    }
                    Section {
                        Picker("Password length", selection: $digits) {
                            ForEach(Digits.allCases) { size in
                                Text(size.localized)
                                    .tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Password length")
                    } footer: {
                        Text("Select the length of the generated password, the longer the password, the more secure it is.")
                    }
                    if typeAlgorithm == .totp {
                        Section {
                            Picker("Period", selection: $period) {
                                ForEach(Period.allCases) { time in
                                    Text(time.localized)
                                        .tag(time)
                                }
                            }
                            .pickerStyle(.segmented)
                        } header: {
                            Text("Period")
                        } footer: {
                            Text("Select a period to update your password.")
                        }
                    } else {
                        Section {
                            Stepper("Present value: ", value: $counter, in: 0 ... 1000)
                        } header: {
                            Text("Counter")
                        } footer: {
                            Text("Set the initial value for the counter, if you are not sure with the choice, leave it at the default.")
                        }
                    }
                    Section {
                        Picker("Encryption type", selection: $algorithm) {
                            ForEach(OTPAlgorithm.allCases) { algorithm in
                                Text(algorithm.rawValue)
                                    .tag(algorithm)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Encryption type")
                    } footer: {
                        Text("Select the type of encryption, if you are not sure with the choice, leave it as default.")
                    }
                    Section {
                        ColorPicker("Password color", selection: $color)
                    } header: {
                        Text("Customization")
                    } footer: {
                        Text("Choose a color for your password to make it easier to find.")
                    }
                }
                #if os(iOS)
                HStack {
                    Button {
                        isShowQRView = true
                    } label: {
                        Image(systemName: "qrcode")
                            .imageScale(.large)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(width: 80)
                    Button(action: savePassword) {
                        Text("Add account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .controlProminence(.increased)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                #endif
            }
            .customAlert(item: $alertItem)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Picker("Algorithm type", selection: $typeAlgorithm.animation()) {
                        ForEach(TypeAlgorithm.allCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    .labelsHidden()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Text("Close")
                    }
                    .keyboardShortcut(.cancelAction)
                }
                #if os(macOS)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add account", action: savePassword)
                        .keyboardShortcut(.defaultAction)
                }
                #endif
            }
            .navigationTitle("New account")
            #if os(iOS)
            .sheet(isPresented: $isShowQRView) {
                QRView(
                    label: $label,
                    issuer: $issuer,
                    secret: $secret,
                    image: $image,
                    period: $period,
                    digits: $digits,
                    algorithm: $algorithm,
                    typeAlgorithm: $typeAlgorithm,
                    counter: $counter
                )
            }
            #endif
        }
        #if os(macOS)
        .padding()
        #endif
        .onOpenURL { url in
            print(url)
        }
    }

    private func savePassword() {
        if label.isEmpty {
            alertItem = AlertItem(message: "Fill in the label field")
        } else if secret.isEmpty {
            alertItem = AlertItem(message: "Fill in the secret field")
        } else {
            guard let secret = base32DecodeToData(secret) else {
                alertItem = AlertItem(message: "The entered secret does not match the base32 encoding")
                return
            }

            let generator = Generator(
                algorithm: algorithm,
                secret: secret,
                factor: typeAlgorithm == .totp
                    ? .timer(period: period.rawValue)
                    : .counter(counter),
                digits: digits.rawValue
            )

            let account = Account(
                label: label,
                issuer: issuer,
                color: color.hexStringFromColor(),
                image: image,
                generator: generator
            )

            appStore.addAccount(account)

            dismiss()
        }
    }
}
