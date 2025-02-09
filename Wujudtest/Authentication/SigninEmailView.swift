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
                let AuthDataResultModel = try await AuthenticationManger.shared.createUser(email: email, password: password)
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
        
        let userId = Auth.auth().currentUser?.uid // Get the authenticated user's ID
        if let userId = userId {
            do {
                let authData = try AuthDataResultModel(user: user) // Pass the actual User object
                try await UserManger.shared.createNewUser(
                    userId: userId, // Pass userId to the method
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
                ExtraFieldsView(viewModel: viewModel) // Pass the entire viewModel
            }
        }
    }
}

struct ExtraFieldsView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var selectedMajor = "Computer Science" // Set default value
    @State private var selectedRole = "Student" // Set default value
    @State private var selectedEducationLevel = "Student" // Set default value
    
    @State private var isNavigating = false // State variable for navigation
    
    let majors = ["Computer Science", "AI"]
    let roles = ["Student", "Employee"]
    let educationLevels = ["Student", "Graduate"]
    
    @ObservedObject var viewModel: SigninEmailViewModel

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

            Picker("Select Major", selection: $selectedMajor) {
                ForEach(majors, id: \.self) { major in
                    Text(major).tag(major)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Picker("Select Role", selection: $selectedRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Picker("Select Education Level", selection: $selectedEducationLevel) {
                ForEach(educationLevels, id: \.self) { level in
                    Text(level).tag(level)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

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
