//
//  AuthManager.swift
//  Wujudtest
//
//  Created by su on 19/02/2025.
//


import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isSignedIn = false
    @Published var isAdmin = false
    @Published var firstName = ""
    @Published var lastName = ""

    private init() {
        checkUserAuthentication()
    }

    func checkUserAuthentication() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("admins").document(user.uid).getDocument { [weak self] (document, error) in
                DispatchQueue.main.async {
                    if let data = document?.data() {
                        self?.isAdmin = true
                        self?.firstName = data["firstName"] as? String ?? ""
                        self?.lastName = data["lastName"] as? String ?? ""
                    } else {
                        self?.isAdmin = false
                    }
                    self?.isSignedIn = true
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            isAdmin = false
            firstName = ""
            lastName = ""
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
}
