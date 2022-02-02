//
//  BorrowItemView.swift
//  final
//
//  Created by Asad Rizvi on 11/18/21.
//

import SwiftUI

struct BorrowItemView: View {
    @State private var showingAlert = false
    @State private var selectedItem = "None"
    @State private var itemCount = 0
    
    var body: some View {
        
        VStack {
            //NavigationView() {
                Form {
                    // Item Selection Section
                    Section(header: Text("Item Selection")) {
                        Picker("Item to borrow", selection: $selectedItem) {
                            ForEach(Item.allCases) { item in
                                Text(item.id)
                            }
                        }
                    }
                    
                    // Item Count Section
                    Section(header: Text("Item Count")) {
                        Stepper("\(itemCount)", value: $itemCount, in: 0...100)
                    }
                    
                    Section() {
                        // Confirm button
                        Button("Confirm") {
                            //onConfirm()
                            showingAlert = true
                        }
                        .padding()
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Confirm Item to Request"),
                                message: Text("Reuqest item to borrow"),
                                primaryButton: .default(Text("Confirm"), action: onConfirm),
                                secondaryButton: .destructive(Text("Cancel"))
                            )
                        }
                        
                        //Cancel button
                        Button("Cancel") {
                            onCancel()
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                }
            //}
        }
        
    }
    
    // Cancel button
    func onCancel() {
        // Segue back to Home Screen
        print("Cancelled")
    }
    
    // Confirm button
    func onConfirm() {
        // Request item from user with it
        print("Confirmed: \(selectedItem), Count: \(itemCount)")
        
        // GETS DESTINATION COORDS FROM FIREBASE
        let latitude = 7.065306
        let longitude = 125.607833
        
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")

        if UIApplication.shared.canOpenURL(url!) {
              UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        else{
              let urlBrowser = URL(string: "https://www.google.co.in/maps/dir/??saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
                        
               UIApplication.shared.open(urlBrowser!, options: [:], completionHandler: nil)
        }
    }
}

struct BorrowItemView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowItemView()
    }
}
