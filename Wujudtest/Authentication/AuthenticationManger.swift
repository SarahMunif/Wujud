import Foundation
import FirebaseAuth

enum AuthError: Error {  //It represents authentication errors
    case missingEmail //It no email enterd
}

struct AuthDataResultModel {
    let uid: String // let is constant means values cannot be changed after initialization
    let email: String
    
    init(user: User) throws { // initializer method for the struct
        self.uid = user.uid
        
        guard let email = user.email else {
            throw AuthError.missingEmail //when email is nil
        }
        
        self.email = email
    }
}

final class AuthenticationManger {
    static let shared = AuthenticationManger()
    private init() {}
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {   //async allows to perform tasks that might take time(network)
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return try AuthDataResultModel(user: authDataResult.user)
    }
}
