import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class SigninEmailViewModel: ObservableObject {
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

    func createNewUser(firstName: String, lastName: String, phoneNumber: String, educationLevel: String, major: String, role: String) async {
        guard let user = user else {
            print("No authenticated user found")
            return
        }
        
        let userId = Auth.auth().currentUser?.uid
        if let userId = userId {
            do {
                let authData = try AuthDataResultModel(user: user)
                try await UserManger.shared.createNewUser(
                    userId: userId,
                    auth: authData,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    educationLevel: educationLevel,
                    major: major,
                    role: role
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

struct SigninEmailView: View {
    @StateObject private var viewModel = SigninEmailViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient (same as AuthenticationView)
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
                    // Title at top
                    HStack {
                        Text("Sign in with Email")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)

                    // Container for textfields & button
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
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.16, green: 0.24, blue: 0.28)) // Dark button color
                                .cornerRadius(25)
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    // Semi-translucent container background
                    .background(
                        Color(red: 0.35, green: 0.45, blue: 0.55).opacity(0.3)
                    )
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationTitle("")  // Hide default title
            .navigationDestination(isPresented: $viewModel.isSignedIn) {
                ExtraFieldsView(viewModel: viewModel)
            }
        }
    }
}
struct ExtraFieldsView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    
    // Default all to "Select" so user must pick explicitly in step 2
    @State private var selectedEducationLevel = "Select"
    @State private var selectedMajor = "Select"
    @State private var selectedRole = "Select"
    
    @State private var isNavigating = false
    @State private var isStep2 = false
    
    let educationLevels = ["Student", "Graduate"]
    let majors = ["Computer Science", "AI"]
    let roles = ["Student", "Employee"]
    
    @ObservedObject var viewModel: SigninEmailViewModel

    var body: some View {
        ZStack {
            // MARK: - Background Gradient
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
                // Title at top
                HStack {
                    Text(isStep2 ? "More Details" : "Sign up")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                
                // MARK: - Container
                VStack(spacing: 20) {
                    if !isStep2 {
                        // STEP 1: First Name, Last Name, Phone Number
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
                            // Move to step 2
                            isStep2 = true
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .fontWeight(.regular)          // Not thick
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 57/255, green: 120/255, blue: 101/255)) // #397865
                                .cornerRadius(25)
                        }
                        
                    } else {
                        // STEP 2: Education Level, Major, Role
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Education Level *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Picker("", selection: $selectedEducationLevel) {
                                Text("Select").tag("Select")
                                ForEach(educationLevels, id: \.self) { level in
                                    Text(level).tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Major *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Picker("", selection: $selectedMajor) {
                                Text("Select").tag("Select")
                                ForEach(majors, id: \.self) { major in
                                    Text(major).tag(major)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Role *")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Picker("", selection: $selectedRole) {
                                Text("Select").tag("Select")
                                ForEach(roles, id: \.self) { role in
                                    Text(role).tag(role)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
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
                                    educationLevel: selectedEducationLevel,
                                    major: selectedMajor,
                                    role: selectedRole
                                )
                                isNavigating = true
                            }
                        } label: {
                            Text("Register")
                                .font(.headline)
                                .fontWeight(.regular)         // Not thick
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
            HomeView() // Navigate to HomeView when isNavigating = true
        }
    }
}
