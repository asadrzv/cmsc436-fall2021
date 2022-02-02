//
//  AddItemView.swift
//  final
//
//  Created by Asad Rizvi on 11/18/21.
//

import SwiftUI
import CoreLocation

// All items a user can add/borrow
enum Item: String, CaseIterable, Identifiable {
    case microUSBPhoneCharger = "Mico USB Charger"
    case miniUSBPhoneCharger = "Mini USB Charger"
    case usbCPhoneCharger = "USB-C Charger"
    case typeCPhoneCharger = "Type-C Charger"
    case magSafe3LaptopCharger = "MagSafe 3 Charger"
    case magSafe2LaptopCharger = "MagSafe 2 Charger"
    case magSafeLaptopCharger = "MagSafe Charger"
    case appleWatchCharger = "Apple Watch Charger"
    
    var id: String { self.rawValue }
}

struct AddItemView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showingAlert = false
    @State private var selectedItem = "None"
    @State private var itemCount = 1
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject private var directory: Directory
    
    @Binding var tabSelection: Int

    var body: some View {
        
        VStack {            
            NavigationView() {
                Form {
                    // Item Selection Section
                    Section(header: Text("Item Selection")) {
                        Picker("Item to add", selection: $selectedItem) {
                            ForEach(Item.allCases) { item in
                                Text(item.id)
                            }
                        }
                    }
                    
                    // Item Count Section
                    Section(header: Text("Item Count")) {
                        Stepper("\(itemCount)", value: $itemCount, in: 1...100)
                    }
                    
                    Section() {
                        // Confirm button
                        Button("Confirm") {
                            showingAlert = true
                        }
                        .padding()
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Confirm Item to Share"),
                                message: Text("Add item for users to borrow"),
                                primaryButton: .default(Text("Confirm"), action: onConfirm),
                                secondaryButton: .destructive(Text("Cancel"), action: {self.showingAlert = false})
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
            }
        }
    }
    
    // Cancel button
    func onCancel() {
        // Segue back to Home Screen
        tabSelection = 0
        self.presentationMode.wrappedValue.dismiss()
    }
    
    // Confirm button
    func onConfirm() {
        // Add item to owner's Firebase database item list
        let lat = locationManager.location.latitude
        let lon = locationManager.location.longitude

        var itemEntry = ItemEntry(id: nil, name: selectedItem, count: itemCount, latitude: lat, longitude: lon, isRequested: false)
        directory.addItemEntry(entry: &itemEntry)
        
        print("Confirmed: \(selectedItem), Count: \(itemCount)")
        
        tabSelection = 0
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(tabSelection: .constant(1))
    }
}
