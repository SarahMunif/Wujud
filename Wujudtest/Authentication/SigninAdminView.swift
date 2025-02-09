//
//  SigninAdminView.swift
//  Wujudtest
//
//  Created by su on 03/02/2025.
//
//
//import SwiftUI
//
//struct SigninAdminView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    SigninAdminView()
//}
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SigninAdminViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSignedIn = false
    @Published var user: User? = nil // Store the Firebase User object

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Please fill in the email or password.")
            return
        }
        Task {
            do {
                let AuthDataResultModel = try await AuthenticationManger.shared.createUser(email: email, password: password)
                print("Success")
                isSignedIn = true
                user = Auth.auth().currentUser // Store the actual User object
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func createNewUser(firstName: String, lastName: String, phoneNumber: String, companyName: String, jobTitle: String, industry: String) async {
        guard let user = user else {
            print("No authenticated user found")
            return
        }
        
        let userId = Auth.auth().currentUser?.uid // Get the authenticated user's ID
        if let userId = userId {
            do {
                let authData = try AuthDataResultModel(user: user) // Pass the actual User object
                try await AdminManger.shared.createNewUser(
                    userId: userId, // Pass userId to the method
                    auth: authData,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    companyName: companyName,
                    jobTitle: jobTitle,
                    industry: industry
                )
                print("User details saved successfully!")
            } catch {
                print("Error saving user details: \(error)")
            }
        } else {
            print("No user ID found")
        }
    }
}

struct SigninAdminView: View {
    @StateObject private var viewModel = SigninAdminViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email ..", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                SecureField("Password ..", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                Button {
                    viewModel.signIn()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Sign in")
            .navigationDestination(isPresented: $viewModel.isSignedIn) {
                ExtraFieldView(viewModel: viewModel) // Pass the entire viewModel
            }
        }
    }
}

struct ExtraFieldView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var companyName = ""
    @State private var jobTitle = ""
    @State private var industry = ""
    
    @State private var isNavigating = false // State variable for navigation
    
 
    
    @ObservedObject var viewModel: SigninAdminViewModel

    var body: some View {
        VStack {
            TextField("First Name", text: $firstName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("company Name", text: $companyName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            TextField("job Title", text: $jobTitle)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            TextField("industry", text: $industry)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            .padding()

            Button {
                Task {
                    await viewModel.createNewUser(
                        firstName: firstName,
                        lastName: lastName,
                        phoneNumber: phoneNumber,
                        companyName: companyName,
                        jobTitle: jobTitle,
                        industry: industry
                    )
                    // Navigate to the next view after user creation
                    isNavigating = true
                }
            } label: {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            // NavigationLink for the next view
            NavigationLink(destination: HomeView(), isActive: $isNavigating) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Extra Fields")
    }
}
