import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class SigninViewModel: ObservableObject {
    
    
    @Published var email = ""
    @Published var password = ""
    @Published var isSignedIn = false
    @Published var isAdmin = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    var didCompleteLoginProcess: (() -> Void)?
 
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true  // Indicate loading state
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            defer { self?.isLoading = false }  // Reset loading state
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {

                case .wrongPassword:
                    self?.errorMessage = "Email and password do not match. Please try again."
                case .invalidEmail:
                    self?.errorMessage = "Invalid email format. Please enter a valid email."
                default:
                    self?.errorMessage = "Email and password do not match. Please try again."
                }
            } else {
                print("✅ User signed in successfully")
                self?.didCompleteLoginProcess?()
                self?.checkUserRole()
                
            }
        }
    }
    
    private func checkUserRole() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("admins").document(user.uid).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user role: \(error)")
                self?.isAdmin = false // Default to regular user if there's an error
            } else {
                if let data = document?.data() {
                    self?.isAdmin = true
                    self?.firstName = data["firstName"] as? String ?? ""
                    self?.lastName = data["lastName"] as? String ?? ""
                } else {
                    self?.isAdmin = false
                }
            }
            self?.isSignedIn = true // Set signed-in status after role check
        }
    }
}
struct SigninView: View {
    @State private var isLoginMode = false
    let didCompleteLoginProcess: () -> Void

    @StateObject private var viewModel = SigninViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Email ..", text: $viewModel.email)
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
                }
                .padding()
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Sign in")
                .onAppear {
                    viewModel.didCompleteLoginProcess = didCompleteLoginProcess
                }
                .navigationDestination(isPresented: $viewModel.isSignedIn) {
                    if viewModel.isAdmin {
                        MainMessagesView() // Pass names here
                    } else {
                        MainMessagesView() // Navigate to HomeView if regular user
                    }
                }
            }
        }
    }
}
