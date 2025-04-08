//
//  BoothInfoView.swift
//  Wujudtest
//
//  Created by su on 14/03/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct BoothInfoView: View {
    @State private var boothData: [String: Any] = [:]
    @State private var errorMessage = ""
    @State private var isEditing = false
    @State private var editedFields: [String: Any] = [:] // Updated to store any type of value (e.g., String, Bool)
    @State private var noBoothFound = false

    // Size options for the picker
    let sizeOptions = ["Startup", "Mid-size", "Enterprise"]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    if noBoothFound {
                        Text("There is no booth for you. Click here to add one.")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                        
                        // Button to navigate to booth creation screen
                        NavigationLink(destination: BoothCreationView()) {
                            Text("Create a Booth")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                        }
                        .padding()
                    } else {
                        // Displaying the Booth Data
                        VStack(alignment: .leading, spacing: 15) {
                            BoothEditableInfoView(title: "Company Name", value: boothData["companyName"] as? String ?? "Not available", key: "companyName", isEditing: $isEditing, editedFields: $editedFields)
                            BoothEditableInfoView(title: "Description", value: boothData["description"] as? String ?? "Not available", key: "description", isEditing: $isEditing, editedFields: $editedFields)
                            BoothEditableInfoView(title: "Industry", value: boothData["industry"] as? String ?? "Not available", key: "industry", isEditing: $isEditing, editedFields: $editedFields)
                            BoothEditableInfoView(title: "Region", value: boothData["region"] as? String ?? "Not available", key: "region", isEditing: $isEditing, editedFields: $editedFields)

                            // Use Picker for size when editing
                            BoothEditableInfoView(title: "Size", value: boothData["size"] as? String ?? "Not available", key: "size", isEditing: $isEditing, editedFields: $editedFields, sizeOptions: sizeOptions)

                            // Seeks Investment, Offers Training, Is Hiring (Boolean values displayed as Yes/No)
                            BoothEditableInfoView(title: "Seeks Investment", value: (boothData["seeksInvestment"] as? Bool ?? false) ? "Yes" : "No", key: "seeksInvestment", isEditing: $isEditing, editedFields: $editedFields, isBoolean: true)
                            BoothEditableInfoView(title: "Offers Training", value: (boothData["offersTraining"] as? Bool ?? false) ? "Yes" : "No", key: "offersTraining", isEditing: $isEditing, editedFields: $editedFields, isBoolean: true)
                            BoothEditableInfoView(title: "Is Hiring", value: (boothData["isHiring"] as? Bool ?? false) ? "Yes" : "No", key: "isHiring", isEditing: $isEditing, editedFields: $editedFields, isBoolean: true)
                        }
                        .padding(.top, 20)
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
            }
            .onAppear {
                fetchBoothData()
            }
        }
    }

    private func fetchBoothData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to fetch: User not logged in"
            return
        }

        Firestore.firestore().collection("booths")
            .whereField("ownerId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch booth data: \(error.localizedDescription)"
                    return
                }
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.boothData = documents.first?.data() ?? [:]
                    self.noBoothFound = false
                } else {
                    self.noBoothFound = true
                }
            }
    }

    private func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to save changes: User not logged in"
            return
        }

        var updatedData: [String: Any] = [:]
        for (key, value) in editedFields {
            updatedData[key] = value
        }

        Firestore.firestore().collection("booths").whereField("ownerId", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch booth for update: \(error.localizedDescription)"
                return
            }
            guard let documents = snapshot?.documents, let document = documents.first else {
                self.errorMessage = "No booth found for this user"
                return
            }

            document.reference.updateData(updatedData) { error in
                if let error = error {
                    self.errorMessage = "Failed to update booth data: \(error.localizedDescription)"
                } else {
                    self.isEditing = false
                    self.editedFields = [:]
                    fetchBoothData() // Refresh the booth data
                }
            }
        }
    }
}

struct BoothEditableInfoView: View {
    var title: String
    var value: String
    var key: String
    @Binding var isEditing: Bool
    @Binding var editedFields: [String: Any]
    var isBoolean: Bool = false
    var sizeOptions: [String]? = nil // For size field only

    var body: some View {
        HStack {
            Text("\(title):")
                .foregroundColor(.white)
                .font(.body)
            
            if isEditing {
                if isBoolean {
                    // Boolean values are toggles
                    Toggle(isOn: Binding(
                        get: { (editedFields[key] as? Bool) ?? (value == "Yes") },
                        set: { editedFields[key] = $0 }
                    )) {
                        Text(value)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding()
                } else if let options = sizeOptions {
                    // Picker for size field
                    Picker("Size", selection: Binding(
                        get: { editedFields[key] as? String ?? value },
                        set: { editedFields[key] = $0 }
                    )) {
                        ForEach(options, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                } else {
                    // Regular TextField for other fields
                    TextField(value, text: Binding(
                        get: { editedFields[key] as? String ?? value },
                        set: { editedFields[key] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                    .padding()
                }
            } else {
                Text(value)
                    .foregroundColor(.white)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
    }
}

#Preview {
    BoothInfoView()
}
