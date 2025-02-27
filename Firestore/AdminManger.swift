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

