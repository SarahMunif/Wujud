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
//                case .invalidEmail:
//                    self?.errorMessage = "Invalid email format. Please enter a valid email."
                default:
                    self?.errorMessage = "Email and password do not match. Please try again."
                }
            } else {
                print("✅ User signed in successfully")
                self?.didCompleteLoginProcess?()
                AdminManger.shared.fetchCurrentUser()
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
                // Fallback: fetch the regular user's data
                UserManger.shared.fetchCurrentUser()
            } else {
                if let data = document?.data() {
                    self?.isAdmin = true
                    self?.firstName = data["firstName"] as? String ?? ""
                    self?.lastName = data["lastName"] as? String ?? ""
                } else {
                    self?.isAdmin = false
                    UserManger.shared.fetchCurrentUser()

                }
            }
            self?.isSignedIn = true // Set signed-in status after role check
        }
    }
}

struct PlaceholderTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.white.opacity(0.7)) // Customize placeholder color here
                    .padding(.leading, 4)
            }
            TextField("", text: $text)
                .foregroundColor(Color.white) // Entered text color
                .autocapitalization(.none)
        }
    }
}

struct SigninView: View {
    @State private var isLoginMode = false
    let didCompleteLoginProcess: () -> Void

    @StateObject private var viewModel = SigninViewModel()

    var body: some View {
        ZStack {
            // MARK: - Updated Gradient Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0x0E / 255, green: 0x2A / 255, blue: 0x34 / 255),  // #0E2A34
                Color(red: 0x58 / 255, green: 0xC0 / 255, blue: 0x91 / 255),  // #58C091
                Color(red: 0x02 / 255, green: 0x10 / 255, blue: 0x24 / 255)   // #021024
            ]),
            startPoint: .top,
            endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer(minLength: 80)

                // Form Container
                VStack(spacing: 20) {
                    // Title
                    HStack {
                        Text("Sign in")
                            .font(.title)         // Reduced size
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    // Subtext
                    HStack(alignment: .top, spacing: 0) {
                        Text("If you don’t have an account register \n you can ")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))
                        NavigationLink(destination: AuthenticationView()) {
                            Text("Register here !")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                        }
                    }
                    

                    // Email Field
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.white)
                        PlaceholderTextField(placeholder: "example@youremail.com", text: $viewModel.email)
                            .autocapitalization(.none)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)

                    // Password Field
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color.white)
                        SecureField("********", text: $viewModel.password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.white)
                        Button(action: {
                            // Optional: Toggle password visibility
                        }) {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }

                    // Sign In Button
                    Button {
                        viewModel.signIn()
                    } label: {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 45)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(25)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .onAppear {
            viewModel.didCompleteLoginProcess = didCompleteLoginProcess
        }
        .navigationDestination(isPresented: $viewModel.isSignedIn) {
            if viewModel.isAdmin {
                AddBoothView()
            } else {
                MainMessagesView()
            }
        }
    }
}
