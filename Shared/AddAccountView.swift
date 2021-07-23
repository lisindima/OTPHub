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
                        TextField("textfield_label", text: $label)
                        TextField("textfield_secret", text: $secret)
                            .disableAutocorrection(true)
                    } header: {
                        Text("section_header_basic_information")
                    }
                    Section {
                        Picker("section_header_digits", selection: $digits) {
                            ForEach(Digits.allCases) { size in
                                Text(size.localized)
                                    .tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("section_header_digits")
                    } footer: {
                        Text("section_footer_digits")
                    }
                    if typeAlgorithm == .totp {
                        Section {
                            Picker("section_header_period", selection: $period) {
                                ForEach(Period.allCases) { time in
                                    Text(time.localized)
                                        .tag(time)
                                }
                            }
                            .pickerStyle(.segmented)
                        } header: {
                            Text("section_header_period")
                        } footer: {
                            Text("section_footer_period")
                        }
                    } else {
                        Section {
                            Stepper("stepper_title_counter", value: $counter, in: 0 ... 1000)
                        } header: {
                            Text("section_header_counter")
                        } footer: {
                            Text("section_footer_counter")
                        }
                    }
                    Section {
                        Picker("section_header_encryption_type", selection: $algorithm) {
                            ForEach(OTPAlgorithm.allCases) { algorithm in
                                Text(algorithm.rawValue)
                                    .tag(algorithm)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("section_header_encryption_type")
                    } footer: {
                        Text("section_footer_encryption_type")
                    }
                    Section {
                        ColorPicker("colorpicker_title", selection: $color)
                    } header: {
                        Text("section_header_customization")
                    } footer: {
                        Text("section_footer_customization")
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
                        Text("button_title_add_account")
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
                    Picker("picker_title_type_algorithm", selection: $typeAlgorithm.animation()) {
                        ForEach(TypeAlgorithm.allCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    .labelsHidden()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Text("close_toolbar")
                    }
                    .keyboardShortcut(.cancelAction)
                }
                #if os(macOS)
                ToolbarItem(placement: .confirmationAction) {
                    Button("button_title_add_account", action: savePassword)
                        .keyboardShortcut(.defaultAction)
                }
                #endif
            }
            .navigationTitle("navigation_title_new_account")
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
            alertItem = AlertItem(message: "alert_empty_label")
        } else if secret.isEmpty {
            alertItem = AlertItem(message: "alert_empty_secret")
        } else {
            guard let secret = base32DecodeToData(secret) else {
                alertItem = AlertItem(message: "alert_wrong_secret")
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
