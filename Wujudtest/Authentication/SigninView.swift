import SwiftUI
import FirebaseAuth

@MainActor
final class SigninViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    self.errorMessage = "Email/password authentication is not enabled."
                case .wrongPassword:
                    self.errorMessage = "Email and password do not match. Please try again."
                case .invalidEmail:
                    self.errorMessage = "Invalid email format. Please enter a valid email."
                default:
                    self.errorMessage = "Authentication failed. Please check your credentials and try again."
                }
            } else {
                print("✅ User signed in successfully")
                self.isSignedIn = true
            }
        }
    }
}

struct SigninView: View {
    @StateObject private var viewModel = SigninViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Email ..", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    SecureField("Password ..", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }

                    Button {
                        viewModel.signIn()
                    } label: {
                        Text("Sign in")
                               .font(.headline)
                               .foregroundStyle(.white)
                               .frame(height: 55)
                               .frame(maxWidth: .infinity)
                               .background(Color.green)
                               .cornerRadius(10)
                       }

                       NavigationLink(destination: HomeView(), isActive: $viewModel.isSignedIn) {
                           EmptyView()
                       }
                   }
                   .padding()
               }
               .scrollDismissesKeyboard(.interactively)
               .navigationTitle("Sign in")
           }
       }
   }
