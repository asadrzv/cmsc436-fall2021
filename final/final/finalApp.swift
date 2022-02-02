//
//  finalApp.swift
//  final
//
//  Created by Asad Rizvi on 11/18/21.
//

import SwiftUI
import Firebase
import FirebaseDatabase

@main
struct finalApp: App {
    @StateObject var locationManager = LocationManager()
    @StateObject var directory = Directory()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(locationManager)
                .environmentObject(directory)
        }
    }
}
