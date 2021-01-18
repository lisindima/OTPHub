//
//  ContentView.swift
//  Shared
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isPresented: Bool = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.passwordName, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
    var body: some View {
        NavigationView {
            LoadingView(items, title: "Пусто", subTitle: "Добавьте свой первый аккаунт.") { items in
                List {
                    ForEach(items) { item in
                        ListItem(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                .modifier(ListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isPresented = true }) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                AddPasswordView()
            }
            .navigationTitle("PasswordHub")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
