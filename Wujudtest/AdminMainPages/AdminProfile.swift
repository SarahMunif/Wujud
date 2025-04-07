//
//  AdminProfile.swift
//  Wujudtest
//
//  Created by su on 11/03/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct AdminProfile: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    @State private var currentUser: [String: Any] = [:]
    @State private var errorMessage = ""
    @State private var showingLocation = false
    @State private var isEditing = false // Track if we are editing
    @State private var editedFields: [String: String] = [:] // To store edited values

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
               
                    HStack {
                        Spacer()
                        Button {
                            shouldShowLogOutOptions.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.white)
                                .padding()
                        }
                        .actionSheet(isPresented: $shouldShowLogOutOptions) {
                            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                                .destructive(Text("Sign out"), action: {
                                    print("Handle sign out")
                                    vm.handelSignOut()
                                }),
                                .cancel()
                            ])
                        }
                        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                            SigninView(didCompleteLoginProcess:{
                                self.vm.isUserCurrentlyLoggedOut = false
                                self.vm.fetchCurrentUser()
                                self.vm.fetchRecentMessage()
                            })
                        }
                    }
//                    .padding(.top, 20) // Adjust the padding as needed

                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 50))
                        .padding(.top, 40)
                }
                .padding(.top, 40)
                VStack {
                    VStack(alignment: .leading, spacing: 15) {


                        EditableInfoView(title: "Job Title", value: currentUser["jobTitle"] as? String ?? "Not available", key: "jobTitle", isEditing: $isEditing, editedFields: $editedFields)
                        EditableInfoView(title: "Industry", value: currentUser["industry"] as? String ?? "Not available", key: "industry", isEditing: $isEditing, editedFields: $editedFields)
                        EditableInfoView(title: "Company", value: currentUser["companyName"] as? String ?? "Not available", key: "companyName", isEditing: $isEditing, editedFields: $editedFields)
        NavigationLink(destination: BoothInfoView()) {
                                      HStack {
                                          Text("Your Booth")
                                              .foregroundColor(.white)
                                              .font(.headline)
                                      }
                                      .padding()
                                      .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2))) // Updated color
                                  }

                              }
                              .padding(.top, 20)
                              .padding(.horizontal, 20)


                    // Contact Info Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Contact Info")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top, 30)

                        EditableInfoView(title: "Email", value: currentUser["email"] as? String ?? "Not available", key: "email", isEditing: $isEditing, editedFields: $editedFields)
                        EditableInfoView(title: "Phone Number", value: currentUser["phoneNumber"] as? String ?? "Not available", key: "phoneNumber", isEditing: $isEditing, editedFields: $editedFields)
                    }
                    .padding(.horizontal, 20)

                    // Save Button when Editing
                    if isEditing {
                        Button(action: saveChanges) {
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                        }
                        .padding(.top, 20)
                    }

                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 20)
                    }

                    // Edit Button (down)
                    if !isEditing {
                        Button(action: {
                            self.isEditing = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        .padding(.top, 30)
                    }
                }
            }
            .onAppear {
                fetchCurrentUser()
            }
        }
    }

    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to fetch: User not logged in"
            return
        }
        Firestore.firestore().collection("admins").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error.localizedDescription)"
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data available"
                return
            }
            self.currentUser = data
        }
    }

    private func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to save changes: User not logged in"
            return
        }

        // Prepare the updated data
        var updatedData: [String: Any] = [:]
        for (key, value) in editedFields {
            updatedData[key] = value
        }

        // Update Firestore
        Firestore.firestore().collection("admins").document(uid).updateData(updatedData) { error in
            if let error = error {
                self.errorMessage = "Failed to update user data: \(error.localizedDescription)"
            } else {
                self.isEditing = false
                self.editedFields = [:] // Reset edited fields
                fetchCurrentUser() // Refresh the data
            }
        }
    }
}

struct EditableInfoView: View {
    var title: String
    var value: String
    var key: String
    @Binding var isEditing: Bool
    @Binding var editedFields: [String: String]

    var body: some View {
        HStack {
            Text("\(title):")
                .foregroundColor(.white)
                .font(.body)
            
            if isEditing {
                TextField(value, text: Binding(
                    get: { editedFields[key] ?? value },
                    set: { editedFields[key] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .padding()
            } else {
                Text(value)
                    .foregroundColor(.white)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2))) // Updated color
    }
}

#Preview {
    AdminProfile()
}
