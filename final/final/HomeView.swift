//
//  HomeView.swift
//  final
//
//  Created by Asad Rizvi on 11/27/21.
//

import SwiftUI
import CoreLocation
import MapKit

extension CLLocationCoordinate2D: Identifiable {
    public var id: String { "\(latitude), \(longitude)" }
}

struct HomeView: View {
    @State private var openAddItemView: Bool = false
    @State private var showBorrowItemAlert: Bool = false
    
    @EnvironmentObject var locationManager: LocationManager
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.98, longitude: -76.94), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @EnvironmentObject private var directory: Directory
    @State var mapItems = [ItemEntry]()
    
    @Binding var tabSelection: Int
    
    var itemKey: String = ""
            
    public var body: some View {
        ZStack {
            // Map to display locations
            Map(coordinateRegion: $coordinateRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: directory.itemEntries) { item in
                
                // Map annotations for borrowable items
                MapAnnotation(coordinate: item.coordinate) {
                    VStack {
                        // User image
                        if item.id == FirebaseManager.shared.auth.currentUser!.uid {
                            // Image to mark item locations (current location)
                            Image(systemName: "bolt.circle.fill")
                                .font(.system(size: 30.0))
                                .onTapGesture(count: 1, perform: {
                                    // Get current user id
                                   guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                                    
                                    // Only open alert to borrow item if it doesn't already belong to the user
                                    if item.id != uid {
                                        self.showBorrowItemAlert = true
                                    }
                                })
                                // Alert to prompt Google Maps route to selected item
                                .alert(isPresented: $showBorrowItemAlert) {
                                    Alert(
                                        title: Text("Confirm \(item.name) to Request "),
                                        message: Text("Request \(item.name) to borrow"),
                                        primaryButton: .default(Text("Confirm"), action: {
                                            self.showBorrowItemAlert = false
                                            self.openGoogleMapDirections()
                                            
                                            for index in 0..<directory.itemEntries.count {
                                                var currentItem = directory.itemEntries[index]
                                                if currentItem.id == item.id {
                                                    currentItem.isRequested = true
                                                }
                                            }
                                        }),
                                        secondaryButton: .destructive(Text("Cancel"), action: {self.showBorrowItemAlert = false})
                                    )
                                }
                        }
                        // Other users' items
                        else {
                            // Image to mark item locations (current location)
                            Image(systemName: "bolt.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 30.0))
                                .onTapGesture(count: 1, perform: {
                                    // Get current user id
                                   guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                                    
                                    // Only open alert to borrow item if it doesn't already belong to the user
                                    if item.id != uid {
                                        self.showBorrowItemAlert = true
                                    }
                                })
                                // Alert to prompt Google Maps route to selected item
                                .alert(isPresented: $showBorrowItemAlert) {
                                    Alert(
                                        title: Text("Confirm \(item.name) to Request "),
                                        message: Text("Request \(item.name) to borrow"),
                                        primaryButton: .default(Text("Confirm"), action: {
                                            self.showBorrowItemAlert = false
                                            self.openGoogleMapDirections()
                                            
                                            for index in 0..<directory.itemEntries.count {
                                                var currentItem = directory.itemEntries[index]
                                                if currentItem.id == item.id {
                                                    currentItem.isRequested = true
                                                    
                                                }
                                            }
                                        }),
                                        secondaryButton: .destructive(Text("Cancel"), action: {self.showBorrowItemAlert = false})
                                    )
                                }
                        }
                    }
                }
            }.onAppear {
                mapItems = directory.itemEntries
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    // Button to open add item screen
                    Button(action: {
                        self.openAddItemView = true
                    }, label: {
                        Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                    })
                    // Launch add item view
                    .sheet(isPresented: $openAddItemView, onDismiss: {self.openAddItemView = false}, content: {
                        AddItemView(tabSelection: .constant(1))
                    })
                    .background(Color.red)
                    .cornerRadius(40)
                    .padding()
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                }
            }
        }
    }
    
    // Confirm button
    func onConfirm() {
        self.showBorrowItemAlert = false
        self.openGoogleMapDirections()
        
        
    }
    
    // Opens Google Map Directions from current location to the location of the item to borrow
    func openGoogleMapDirections() {
        let latitude = locationManager.location.latitude
        let longitude = locationManager.location.longitude
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")

        // Launch Google Maps iOS app
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        // Otherwise launch Google Maps web app if iOS app not available
        else {
            let urlBrowser = URL(string: "https://www.google.com/maps/dir/??saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
            UIApplication.shared.open(urlBrowser!, options: [:], completionHandler: nil)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabSelection: .constant(0))
    }
}
