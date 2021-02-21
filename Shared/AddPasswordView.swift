//
//  AddPasswordView.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI
import SwiftOTP

struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject private var appStore: AppStore
    
    @State private var passwordName: String = ""
    @State private var passwordSecret: String = ""
    @State private var updateTime: UpdateTime = .thirtySeconds
    @State private var sizePassword: SizePassword = .sixDigit
    @State private var passwordAlgorithm: PasswordAlgorithm = .sha1
    @State private var typeAlgorithm: TypeAlgorithm = .totp
    @State private var passwordCounter: Int = 0
    @State private var passwordColor: Color = .black
    @State private var isShowAlert: Bool = false
    @State private var isShowQRView: Bool = false
    
    func savePassword() {
        guard let secret = base32DecodeToData(passwordSecret) else { return }
        
        let generator = Generator(
            algorithm: passwordAlgorithm,
            secret: secret,
            factor: typeAlgorithm == .totp
                ? .timer(period: TimeInterval(updateTime.rawValue))
                : .counter(UInt64(passwordCounter)),
            digits: sizePassword.rawValue.toInt()
        )
        
        let account = Account(
            label: passwordName,
            issuer: nil,
            color: passwordColor.hexStringFromColor(),
            imageURL: nil, generator: generator
        )
        
        appStore.addAccount(account)
    }
    
//    private func savePassword() {
//        if passwordName.isEmpty || passwordSecret.isEmpty {
//            isShowAlert = true
//        } else {
//            let item = Item(context: moc)
//            item.passwordName = passwordName
//            item.passwordSecret = passwordSecret
//            item.passwordAlgorithm = passwordAlgorithm.rawValue
//            item.typeAlgorithm = typeAlgorithm.rawValue
//            item.updateTime = updateTime.rawValue
//            item.sizePassword = sizePassword.rawValue
//            item.passwordCounter = passwordCounter.toInt32()
//            item.passwordColor = passwordColor.hexStringFromColor()
//            do {
//                try moc.save()
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                let nsError = error as NSError
//                print("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
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
                            Picker("section_header_update_time", selection: $updateTime) {
                                ForEach(UpdateTime.allCases) { time in
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
                            ForEach(PasswordAlgorithm.allCases) { algorithm in
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
                updateTime: $updateTime,
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
