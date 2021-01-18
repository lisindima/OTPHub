//
//  ListItem.swift
//  PasswordHub
//
//  Created by Дмитрий Лисин on 18.01.2021.
//

import SwiftUI

struct ListItem: View {
    var item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.passwordSecret!)
            Text(item.passwordName!)
            Text(item.passwordColor!)
            Text("\(item.sizePassword)")
            Text("\(item.updateTime)")
        }
    }
}
