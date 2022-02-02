//
//  LoginView.swift
//  final
//
//  Created by Asad Rizvi on 11/18/21.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
//import FirebaseFirestore

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let database: Database
    //let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        //self.firestore = Firestore.firestore()
        self.database = Database.database()
        super.init()
    }
}

struct LoginView: View {
    @State private var loggedIn: Bool = false
    @State private var loginStatusMessage: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject private var directory: Directory
    
    @State var tabSelection = 0

    var body: some View {
        // Segue to Home screen if user has succesfully logged-in
        if loggedIn {
            TabView(selection: $tabSelection) {
                HomeView(tabSelection: $tabSelection)
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map").font(.title)
                    }.tag(0)
                
                AddItemView(tabSelection: $tabSelection)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item").font(.title)
                    }.tag(1)
                
                ItemListView()
                    .tabItem {
                        Image(systemName: "bolt.circle.fill")
                        Text("My Items").font(.title)
                    }.tag(2)
                
            }.accentColor(.blue)
        
        // Display login view to prompt user to login/signup
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 90))
                        .padding(40)
                    
                    Group {
                        // Get email from user
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        // Get password from user
                        SecureField("Password", text: $password)
                    }
                    .padding(15)
                    .background(Color.white)
                    
                    VStack {
                        // Login button
                        Button(action: onLogin) {
                            Text("Login")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(15)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(40)
                        
                        // Signup button
                        Button(action: onSignUp) {
                            Text("Sign Up")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(15)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(40)
                    }
                    .padding(15)

                    // Login status message
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                }.padding()
            }.background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
    }

    // Login user using entered email/password
    private func onLogin() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user!"
                return
            }
            
            loggedIn = true
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.storeUserInformation()
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }
    
    // SignUp user using entered email/password
    private func onSignUp() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user!"
                return
            }
            
            loggedIn = true
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.storeUserInformation()
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
        }
    }
    
    // Stores user info to Firbase database
    private func storeUserInformation() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        var userEntry = UserEntry(id: uid, email: email, password: password, date: Date().description)
        directory.addUserEntry(entry: &userEntry)
    }
}

struct LoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        LoginView()
    }
}
