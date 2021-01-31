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

    @Binding var isPresented: Bool
    @State private var showIndicator: Bool = false
    
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
        List {
            ForEach(items) { item in
                ListItem(item: item, showIndicator: $showIndicator)
            }
            .onDelete(perform: deleteItems)
        }
        .modifier(ListStyle())
        .environment(\.defaultMinListRowHeight, 70)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isPresented = true }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
                .help("help_title_add_button")
            }
        }
        .sheet(isPresented: $isPresented) {
            AddPasswordView()
                .accentColor(.purple)
        }
        .empedInNavigation(title: "OTPHub")
        .toast(isPresented: $showIndicator)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isPresented: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
