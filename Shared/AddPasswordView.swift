//
//  AddPasswordView.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI
import CodeScanner

struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var passwordName: String = ""
    @State private var passwordSecret: String = ""
    @State private var updateTime: UpdateTime = .thirtySeconds
    @State private var sizePassword: SizePassword = .sixDigit
    @State private var passwordColor: Color = .black
    @State private var isPresented: Bool = false
    @State private var showQRView: Bool = false
    
    private func savePassword() {
        if passwordName.isEmpty || passwordSecret.isEmpty {
            isPresented = true
        } else {
            let item = Item(context: moc)
            item.passwordName = passwordName
            item.passwordSecret = passwordSecret
            item.updateTime = Int32(updateTime.rawValue)
            item.sizePassword = Int32(sizePassword.rawValue)
            item.passwordColor = "#ff0000"
            do {
                try moc.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Основная информация")) {
                        TextField("Имя", text: $passwordName)
                        TextField("Секрет", text: $passwordSecret)
                    }
                    Section(header: Text("Длина пароля")) {
                        Picker("Длина пароля", selection: $sizePassword) {
                            Text("6 знаков").tag(SizePassword.sixDigit)
                            Text("7 знаков").tag(SizePassword.sevenDigit)
                            Text("8 знаков").tag(SizePassword.eightDigit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Section(header: Text("Время обновления")) {
                        Picker("Время обновления", selection: $updateTime) {
                            Text("30 секунд").tag(UpdateTime.thirtySeconds)
                            Text("60 секунд").tag(UpdateTime.sixtySeconds)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Section(header: Text("Кастомизация"), footer: Text("Выберите цвет для пароля чтобы удобнее было его найти.")) {
                        ColorPicker("Цвет пароля", selection: $passwordColor)
                    }
                }
                CustomButton("Добавить", action: savePassword)
                    .shadow(radius: 6)
                    .padding()
            }
            .navigationTitle("Новый аккаунт")
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Ошибка"), message: Text("Заполните все поля"), dismissButton: .cancel())
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showQRView = true }) {
                        Image(systemName: "qrcode")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showQRView) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: "otpauth://totp/VK:lisindima?secret=P6WV3X36LTK756DL&issuer=VK"
                ) { result in
                    switch result {
                    case let .success(code):
                        print("Found code: \(code)")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
