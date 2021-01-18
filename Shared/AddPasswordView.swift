//
//  AddPasswordView.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var passwordName: String = ""
    @State private var passwordSecret: String = ""
    @State private var updateTime: UpdateTime = .thirtySeconds
    @State private var sizePassword: SizePassword = .eightDigit
    @State private var accentColor: Color = .black
    @State private var isPresented: Bool = false
    
    private func savePassword() {
        if passwordName.isEmpty || passwordSecret.isEmpty {
            isPresented = true
        } else {
            let item = Item(context: moc)
            item.passwordName = passwordName
            item.passwordSecret = passwordSecret
            item.updateTime = Int32(updateTime.rawValue)
            item.sizePassword = Int32(sizePassword.rawValue)
            item.passwordColor = "#00000"
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
                        ColorPicker("Цвет пароля", selection: $accentColor)
                    }
                }
                CustomButton("Добавить", action: savePassword)
                    .padding()
            }
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Ошибка"), message: Text("Заполните все поля"), dismissButton: .cancel())
            }
            .navigationTitle("Новый аккаунт")
        }
    }
}

enum SizePassword: Int, CaseIterable, Identifiable {
    case sixDigit = 6
    case sevenDigit = 7
    case eightDigit = 8

    var id: Int { self.rawValue }
}

enum UpdateTime: Int, CaseIterable, Identifiable {
    case thirtySeconds = 30
    case sixtySeconds = 60

    var id: Int { self.rawValue }
}
