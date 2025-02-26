import Foundation
import FirebaseAuth

enum AuthError: Error {
    case missingEmail
    case noCurrentUser
}

struct AuthDataResultModel {
    let uid: String
    let email: String
    
    init(user: User) throws {
        self.uid = user.uid
        
        guard let email = user.email else {
            throw AuthError.missingEmail
        }
        
        self.email = email
    }
}

final class AuthenticationManger {
    static let shared = AuthenticationManger()
    let auth = Auth.auth() // Exposing Firebase Auth to be used elsewhere

    private init() {}

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await auth.createUser(withEmail: email, password: password)
        return try AuthDataResultModel(user: authDataResult.user)
    }
}
