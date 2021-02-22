//
//  AddPasswordView.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import OTP
import SwiftUI

struct AddPasswordView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject private var appStore: AppStore
    
    @State private var passwordName: String = ""
    @State private var passwordSecret: String = ""
    @State private var period: Period = .thirty
    @State private var sizePassword: SizePassword = .six
    @State private var passwordAlgorithm: OTPAlgorithm = .sha1
    @State private var typeAlgorithm: TypeAlgorithm = .totp
    @State private var passwordCounter: UInt64 = 0
    @State private var passwordColor: Color = .black
    @State private var isShowAlert: Bool = false
    @State private var isShowQRView: Bool = false
    
    private func savePassword() {
        if passwordName.isEmpty || passwordSecret.isEmpty {
            isShowAlert = true
        } else {
            guard let secret = base32DecodeToData(passwordSecret) else {
                isShowAlert = true
                return
            }
            
            let generator = Generator(
                algorithm: passwordAlgorithm,
                secret: secret,
                factor: typeAlgorithm == .totp
                    ? .timer(period: period.rawValue)
                    : .counter(passwordCounter),
                digits: sizePassword.rawValue
            )
            
            let account = Account(
                label: passwordName,
                issuer: nil,
                color: passwordColor.hexStringFromColor(),
                imageURL: nil, generator: generator
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
                        TextField("textfield_name", text: $passwordName)
                        TextField("textfield_secret", text: $passwordSecret)
                            .disableAutocorrection(true)
                    }
                    .macOS { $0.textFieldStyle(RoundedBorderTextFieldStyle()) }
                    Section(
                        header: Text("section_header_password_length"),
                        footer: Text("section_footer_password_length")
                    ) {
                        Picker("section_header_password_length", selection: $sizePassword) {
                            ForEach(SizePassword.allCases) { size in
                                Text(size.localized)
                                    .tag(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }
                    if typeAlgorithm == .totp {
                        Section(
                            header: Text("section_header_update_time"),
                            footer: Text("section_footer_update_time")
                        ) {
                            Picker("section_header_update_time", selection: $period) {
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
                            header: Text("section_header_password_counter"),
                            footer: Text("section_footer_password_counter")
                        ) {
                            #if os(iOS)
                            Stepper("stepper_title_password_counter \(passwordCounter)", value: $passwordCounter, in: 0 ... 1000)
                            #else
                            HStack {
                                Text("stepper_title_password_counter \(passwordCounter)")
                                Spacer()
                                Stepper("", value: $passwordCounter, in: 0 ... 1000)
                                    .labelsHidden()
                            }
                            #endif
                        }
                    }
                    Section(
                        header: Text("section_header_encryption_type"),
                        footer: Text("section_footer_encryption_type")
                    ) {
                        Picker("section_header_encryption_type", selection: $passwordAlgorithm) {
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
                        ColorPicker("colorpicker_title", selection: $passwordColor)
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
            .alert(isPresented: $isShowAlert) {
                Alert(
                    title: Text("alert_error_title"),
                    message: Text("alert_error_message"),
                    dismissButton: .cancel()
                )
            }
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
                passwordName: $passwordName,
                passwordSecret: $passwordSecret,
                period: $period,
                sizePassword: $sizePassword,
                passwordAlgorithm: $passwordAlgorithm,
                typeAlgorithm: $typeAlgorithm,
                passwordCounter: $passwordCounter
            )
            .accentColor(.purple)
            #endif
        }
    }
}
