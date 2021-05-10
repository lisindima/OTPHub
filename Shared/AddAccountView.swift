//
//  AddAccountView.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import KeychainOTP
import SwiftUI

struct AddAccountView: View {
    @Environment(\.presentationMode) private var presentationMode

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

            presentationMode.wrappedValue.dismiss()
        }
    }

    private func showQRView() {
        isShowQRView = true
    }

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationViewWrapper {
            VStack {
                Form {
                    Section(header: Text("section_header_basic_information")) {
                        TextField("textfield_label", text: $label)
                        TextField("textfield_secret", text: $secret)
                            .disableAutocorrection(true)
                    }
                    .macOS { $0.textFieldStyle(RoundedBorderTextFieldStyle()) }
                    Section(
                        header: Text("section_header_digits"),
                        footer: Text("section_footer_digits")
                    ) {
                        Picker("section_header_digits", selection: $digits) {
                            ForEach(Digits.allCases) { size in
                                Text(size.localized)
                                    .tag(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }
                    if typeAlgorithm == .totp {
                        Section(
                            header: Text("section_header_period"),
                            footer: Text("section_footer_period")
                        ) {
                            Picker("section_header_period", selection: $period) {
                                ForEach(Period.allCases) { time in
                                    Text(time.localized)
                                        .tag(time)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .labelsHidden()
                        }
                    } else {
                        Section(
                            header: Text("section_header_counter"),
                            footer: Text("section_footer_counter")
                        ) {
                            #if os(iOS)
                            Stepper(value: $counter, in: 0 ... 1000) {
                                Text("stepper_title_counter") + Text("\(counter)").fontWeight(.bold)
                            }
                            #else
                            HStack {
                                Text("stepper_title_counter") + Text("\(counter)").fontWeight(.bold)
                                Spacer()
                                Stepper("", value: $counter, in: 0 ... 1000)
                                    .labelsHidden()
                            }
                            #endif
                        }
                    }
                    Section(
                        header: Text("section_header_encryption_type"),
                        footer: Text("section_footer_encryption_type")
                    ) {
                        Picker("section_header_encryption_type", selection: $algorithm) {
                            ForEach(OTPAlgorithm.allCases) { algorithm in
                                Text(algorithm.rawValue)
                                    .tag(algorithm)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }
                    Section(
                        header: Text("section_header_customization"),
                        footer: Text("section_footer_customization")
                    ) {
                        ColorPicker("colorpicker_title", selection: $color)
                            .macOS { $0.labelsHidden() }
                            .macOS { $0.frame(height: 50) }
                    }
                }
                #if os(iOS)
                HStack {
                    Button(action: showQRView) {
                        Image(systemName: "qrcode")
                            .imageScale(.large)
                    }
                    .buttonStyle(
                        CustomButtonStyle(
                            backgroundColor: .accentColor.opacity(0.2),
                            labelColor: .accentColor
                        )
                    )
                    .frame(width: 80)
                    Button("button_title_add_account", action: savePassword)
                        .buttonStyle(CustomButtonStyle())
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
                    Button(action: dismissView) {
                        Label("close_toolbar", systemImage: "xmark")
                            .labelStyle(CustomLabelStyle())
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
        }
        .macOS { $0.padding() }
        .onOpenURL { url in
            print(url)
        }
        .sheet(isPresented: $isShowQRView) {
            #if os(iOS)
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
            .accentColor(.purple)
            #endif
        }
    }
}
