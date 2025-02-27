//
//  UserManger.swift
//  Wujudtest
//
//  Created by su on 02/02/2025.
//

import Foundation
import FirebaseFirestore

class UserManger {
    static let shared = UserManger()

    // Modify createNewUser to accept userId
    func createNewUser(userId: String, auth: AuthDataResultModel, firstName: String, lastName: String, phoneNumber: String, educationLevel: String, major: String, role: String) async throws {
        let db = Firestore.firestore()

        // Create a dictionary with the user data
        let userData: [String: Any] = [
            "uid": userId,  
            "email": auth.email,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "educationLevel": educationLevel,
            "major": major,
            "role": role
        ]

        // Save data to Firestore under the path 'users/{userId}'
        try await db.collection("users").document(userId).setData(userData)
        print("User data saved successfully!")
    }
}

