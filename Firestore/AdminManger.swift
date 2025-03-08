//
//  UserManger.swift
//  Wujudtest
//
//  Created by su on 02/02/2025.
//

import Foundation
import FirebaseFirestore

class AdminManger {
    static let shared = AdminManger()
    let firestore = Firestore.firestore()
    var currentUser: ChatUser?

    func fetchCurrentUser() {
        guard let uid = AuthenticationManger.shared.auth.currentUser?.uid else { return }
        firestore.collection("admins").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: \(error)")
                return
            }
            guard let data = snapshot?.data() else { return }
            self.currentUser = ChatUser(data: data)
            print("Current user is now \(self.currentUser?.firstName ?? "nil")")
        }
    }

    // Modify createNewUser to accept userId
    func createNewUser(userId: String, auth: AuthDataResultModel, firstName: String, lastName: String, phoneNumber: String, companyName: String, jobTitle: String, industry: String) async throws {
        let db = Firestore.firestore()

        // Create a dictionary with the user data
        let userData: [String: Any] = [
            "uid": userId,  // Ensuring UID is also explicitly stored if needed
            "email": auth.email,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "companyName": companyName,
            "jobTitle": jobTitle,
            "industry": industry
        ]

        // Save data to Firestore under the path 'users/{userId}'
        try await db.collection("admins").document(userId).setData(userData)
        print("User data saved successfully!")
    }
}

