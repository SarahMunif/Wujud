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
                _ = try await AuthenticationManger.shared.createUser(email: email, password: password)
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
        
        let userId = Auth.auth().currentUser?.uid
        if let userId = userId {
            do {
                let authData = try AuthDataResultModel(user: user)
                try await AdminManger.shared.createNewUser(
                    userId: userId,
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
            ZStack {
                // Gradient Background matching AuthenticationView
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 0.40, green: 0.48, blue: 0.54), // Lighter teal-ish
//                        Color(red: 0.01, green: 0.06, blue: 0.14)  // Darker color
//                    ]),
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0x0E / 255, green: 0x2A / 255, blue: 0x34 / 255),  // #0E2A34
                    Color(red: 0x58 / 255, green: 0xC0 / 255, blue: 0x91 / 255),  // #58C091
                    Color(red: 0x02 / 255, green: 0x10 / 255, blue: 0x24 / 255)   // #021024
                ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    // Title aligned to left
                    HStack {
                        Text("Sign in as Admin")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                    
                    // Container for sign in fields
                    VStack(spacing: 20) {
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
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 57/255, green: 120/255, blue: 101/255)) // #397865
                                .cornerRadius(25)
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(
                        Color(red: 0.35, green: 0.45, blue: 0.55).opacity(0.3)
                    )
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationDestination(isPresented: $viewModel.isSignedIn) {
                // Navigate to the ExtraFieldView after sign in
                ExtraFieldView(viewModel: viewModel)
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
    
    @State private var isNavigating = false
    @State private var isStep2 = false  // Controls form step
    
    @ObservedObject var viewModel: SigninAdminViewModel
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0x0E / 255, green: 0x2A / 255, blue: 0x34 / 255),  // #0E2A34
                Color(red: 0x58 / 255, green: 0xC0 / 255, blue: 0x91 / 255),  // #58C091
                Color(red: 0x02 / 255, green: 0x10 / 255, blue: 0x24 / 255)   // #021024
            ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                // Title (changes based on step)
                HStack {
                    Text(isStep2 ? "More Details" : "Extra Fields")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                
                // Container
                VStack(spacing: 20) {
                    if !isStep2 {
                        // Step 1: Basic Info
                        VStack(alignment: .leading, spacing: 5) {
                            Text("First Name *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $firstName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Last Name *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $lastName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Phone Number *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        // Next Button
                        Button {
                            isStep2 = true
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 57/255, green: 120/255, blue: 101/255)) // #397865
                                .cornerRadius(25)
                        }
                    } else {
                        // Step 2: Admin Details
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Company Name *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $companyName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Job Title *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $jobTitle)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Industry *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("", text: $industry)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        // Register Button
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
                                isNavigating = true
                            }
                        } label: {
                            Text("Register")
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 57/255, green: 120/255, blue: 101/255)) // #397865
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .background(
                    Color(red: 0.35, green: 0.45, blue: 0.55).opacity(0.3)
                )
                .cornerRadius(30)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationDestination(isPresented: $isNavigating) {
            AdminCongratsView()
        }
    }
}
