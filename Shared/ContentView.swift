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
        #if os(watchOS)
        list
        #elseif os(macOS)
        list
            .toast(isPresented: $showIndicator)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: nil, minHeight: 340, idealHeight: 440, maxHeight: nil)
        #else
        list
            .toast(isPresented: $showIndicator)
        #endif
    }
    
    var list: some View {
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
            }
        }
        .sheet(isPresented: $isPresented) {
            AddPasswordView()
                .accentColor(.purple)
        }
        .navigationTitle("OTPHub")
        .navigationView()
        .modifier(NavigationStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
