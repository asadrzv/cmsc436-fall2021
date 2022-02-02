//
//  ItemListView.swift
//  final
//
//  Created by Asad Rizvi on 12/4/21.
//

import SwiftUI

struct ItemListView: View {
    @EnvironmentObject private var directory: Directory
    @State var userItems: [ItemEntry] = [ItemEntry]()
    private var itemStatus: String = ""

    var body: some View {
        Form {
            ForEach(0..<directory.itemEntries.count, id: \.self) { i in
                let item = directory.itemEntries[i]
                
                let itemStatus = item.isRequested ? "Requested" : "Not Requested"
                
                if item.id == FirebaseManager.shared.auth.currentUser!.uid {
                    Section(header: Text("\(item.name)")) {
                        Text("Count: \(item.count) \nStatus: \(itemStatus)")
                    }
                }
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
