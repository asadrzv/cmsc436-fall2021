//
//  Directory.swift
//  final
//
//  Created by Asad Rizvi on 12/4/21.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase

// User Entry
struct UserEntry: Codable, Identifiable {
    var id: String?
    var email: String
    var password: String
    var date: String

    var dict: NSDictionary? {
        if let idStr = id {
            let dict = NSDictionary(dictionary: ["id": idStr,
                                                 "email": email,
                                                 "password": password,
                                                 "date": Date().description])
            return dict
        }
        return nil
    }
    
    static func fromDict(_ dict: NSDictionary) -> UserEntry? {
        guard let email = dict["email"] as? String else { return nil }
        guard let password = dict["password"] as? String else { return nil }
        guard let date = dict["date"] as? String else { return nil }
        
        return UserEntry(id: dict["id"] as? String,
                         email: email,
                         password: password,
                         date: date)
    }
}

// Item Entry
struct ItemEntry: Codable, Identifiable {
    var id: String?
    var name: String
    var count: Int
    var latitude: Double
    var longitude: Double
    var isRequested: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var dict: NSDictionary? {
        if let idStr = id {
            let dict = NSDictionary(dictionary: ["id": idStr,
                                                 "name": name,
                                                 "count": count,
                                                 "latitude": latitude,
                                                 "longitude": longitude,
                                                 "isRequested": isRequested])
            return dict
        }
        return nil
    }
    
    static func fromDict(_ dict: NSDictionary) -> ItemEntry? {
        guard let name = dict["name"] as? String else { return nil }
        guard let count = dict["count"] as? Int else { return nil }
        guard let latitude = dict["latitude"] as? Double else { return nil }
        guard let longitude = dict["longitude"] as? Double else { return nil }
        guard let isRequested = dict["isRequested"] as? Bool else { return nil }
        
        return ItemEntry(id: dict["id"] as? String,
                         name: name,
                         count: count,
                         latitude: latitude,
                         longitude: longitude,
                         isRequested: isRequested)
    }
}

class Directory: ObservableObject {
    @Published var userEntries: [String:UserEntry] = [:]
    @Published var itemEntries = [ItemEntry]()
    
    init() {
        let root = Database.database().reference()
        
        let usersRoot = Database.database().reference(withPath: "users")
        let itemsRoot = Database.database().reference(withPath: "items")
        
        // Gets all User entries
        root.child("users").getData { err, snapshot in
            DispatchQueue.main.async {
                for child in snapshot.children {
                    if let item = child as? DataSnapshot {
                        if let val = item.value as? NSDictionary,
                           let entry = UserEntry.fromDict(val),
                           let id = entry.id { self.userEntries[id] = entry }
                    }
                }
            }
        }

        // Gets all Item entries
        root.child("items").getData { err, snapshot in
            DispatchQueue.main.async {
                for child in snapshot.children {
                    if let item = child as? DataSnapshot {
                        if let val = item.value as? NSDictionary,
                           let entry = ItemEntry.fromDict(val) {
                            self.itemEntries.append(entry)
                        }
                    }
                }
            }
        }
        
        // User observer for adding entries
        usersRoot.observe(.childAdded) { snapshot in
            if let val = snapshot.value as? NSDictionary,
               let entry = UserEntry.fromDict(val),
               let id = entry.id { self.userEntries[id] = entry }
        }
        
        // Item observer for adding entries
        itemsRoot.observe(.childAdded) { snapshot in
            if let val = snapshot.value as? NSDictionary,
               let entry = ItemEntry.fromDict(val) {
                self.itemEntries.append(entry)
            }
        }

        // User observer for updating entries
        usersRoot.observe(.childChanged) { snapshot in
            if let val = snapshot.value as? NSDictionary,
               let entry = UserEntry.fromDict(val),
               let id = entry.id { self.userEntries[id] = entry }
        }
        
        // Item observer for updating entries
        itemsRoot.observe(.childChanged) { snapshot in
            DispatchQueue.main.async {
                for child in snapshot.children {
                    if let item = child as? DataSnapshot {
                        if let val = item.value as? NSDictionary,
                           let entry = ItemEntry.fromDict(val) {
                            self.itemEntries.append(entry)
                        }
                    }
                }
            }
        }
    }
    
    // Add User entry to Firebase Realtime Database
    func addUserEntry(entry: inout UserEntry) {
        // Get current user id
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        let root = Database.database().reference()
        let childRef = root.child("users").child(uid) // User id matches their authentication uid
        entry.id = childRef.key
        
        if let val = entry.dict {
            childRef.setValue(val)
        }
    }
    
    // Add Item entry to Firebase Realtime Database
    func addItemEntry(entry: inout ItemEntry) {
        // Get current user id
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        let root = Database.database().reference()
        let childRef = root.child("items").childByAutoId() // Item unique id
        entry.id = uid // Item stores has its owner's uid
        
        if let val = entry.dict {
            childRef.setValue(val)
        }
    }
}
