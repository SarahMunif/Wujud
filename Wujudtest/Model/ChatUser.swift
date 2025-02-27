//
//  ChatUser.swift
//  Wujudtest
//
//  Created by su on 27/02/2025.
//

import Foundation

struct ChatUser: Identifiable {
    var id : String { uid }
    let uid, email, firstName, lastName: String
    
    var username: String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        return String(email[..<atIndex])
    }
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
    }
}
