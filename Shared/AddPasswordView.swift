//
//  AddPasswordView.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

#if os(iOS)
import CodeScanner
#endif
import SwiftUI

struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var passwordName: String = ""
    @State private var passwordSecret: String = ""
    @State private var updateTime: UpdateTime = .thirtySeconds
    @State private var sizePassword: SizePassword = .sixDigit
    @State private var passwordAlgorithm: PasswordAlgorithm = .sha1
    @State private var passwordColor: Color = .purple
    @State private var isPresented: Bool = false
    @State private var showQRView: Bool = false
    
    private func savePassword() {
        if passwordName.isEmpty || passwordSecret.isEmpty {
            isPresented = true
        } else {
            let hexString = passwordColor.hexStringFromColor()
            let item = Item(context: moc)
            item.passwordName = passwordName
            item.passwordSecret = passwordSecret
            item.passwordAlgorithm = passwordAlgorithm.rawValue
            item.updateTime = Int32(updateTime.rawValue)
            item.sizePassword = Int32(sizePassword.rawValue)
            item.passwordColor = hexString
            do {
                try moc.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
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
        #if os(iOS)
        NavigationView {
            form
                .sheet(isPresented: $showQRView) {
                    CodeScannerView(
                        codeTypes: [.qr],
                        simulatedData: "otpauth://totp/foo?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA====&algorithm=SHA256&digits=8"
                    ) { result in
                        switch result {
                        case let .success(code):
                            getURLComponents(URL(string: code)!)
                            showQRView = false
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
        }
        #else
        form
            .padding()
        #endif
    }
    
    var form: some View {
        VStack {
            Form {
                Section(header: Text("section_header_basic_information")) {
                    TextField("textfield_name", text: $passwordName)
                        .customTextField()
                    TextField("textfield_secret", text: $passwordSecret)
                        .customTextField()
                }
                Section(header: Text("section_header_password_length")) {
                    Picker("section_header_password_length", selection: $sizePassword) {
                        ForEach(SizePassword.allCases) { size in
                            Text(size.localized)
                                .tag(size)
                        }
                    }
                    .labelsHidden()
                }
                .pickerStyle(SegmentedPickerStyle())
                Section(header: Text("section_header_update_time")) {
                    Picker("section_header_update_time", selection: $updateTime) {
                        ForEach(UpdateTime.allCases) { time in
                            Text(time.localized)
                                .tag(time)
                        }
                    }
                    .labelsHidden()
                }
                .pickerStyle(SegmentedPickerStyle())
                Section(header: Text("section_header_encryption_type")) {
                    Picker("section_header_encryption_type", selection: $passwordAlgorithm) {
                        ForEach(PasswordAlgorithm.allCases) { algorithm in
                            Text(algorithm.rawValue)
                                .tag(algorithm)
                        }
                    }
                    .labelsHidden()
                }
                .pickerStyle(SegmentedPickerStyle())
                Section(header: Text("section_header_customization"), footer: Text("section_footer_customization")) {
                    ColorPicker("colorpicker_title", selection: $passwordColor)
                        .colorPickerMac()
                }
            }
            #if os(iOS)
            Button(action: savePassword) {
                Text("button_title_add_account")
                    .fontWeight(.bold)
            }
            .buttonStyle(CustomButton())
            #endif
        }
        .navigationTitle("navigation_title_new_account")
        .alert(isPresented: $isPresented) {
            Alert(title: Text("alert_error_title"), message: Text("alert_error_message"), dismissButton: .cancel())
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    #if os(iOS)
                    Image(systemName: "xmark")
                    #else
                    Text("close_toolbar")
                    #endif
                }
                .keyboardShortcut(.cancelAction)
            }
            #if os(iOS)
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showQRView = true }) {
                    Image(systemName: "qrcode")
                        .imageScale(.large)
                }
            }
            #else
            ToolbarItem(placement: .confirmationAction) {
                Button(action: savePassword) {
                    Text("button_title_add_account")
                }
                .keyboardShortcut(.defaultAction)
            }
            #endif
        }
    }
}
