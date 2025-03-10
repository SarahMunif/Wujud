import FirebaseFirestore
import FirebaseAuth

class BoothManager {
    static let shared = BoothManager()
    
    let firestore = Firestore.firestore()
    
    // Function to create a new booth and link it to the current admin user
    func createBooth(
        companyName: String,
        description: String,
        industry: String,
        region: String,
        size: String,
        seeksInvestment: Bool,
        offersTraining: Bool,
        isHiring: Bool
    ) {
        // Check if a user is signed in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user is signed in, or the auth state is not refreshed.")
            return
        }
        
        // Print the current user ID for debugging
        print("Current user ID: \(currentUserId)")
        
        let boothRef = firestore.collection("booths").document()
        
        // Prepare data to be written to Firestore
        let boothData: [String: Any] = [
            "companyName": companyName,
            "description": description,
            "industry": industry,
            "region": region,
            "size": size,
            "seeksInvestment": seeksInvestment,
            "offersTraining": offersTraining,
            "isHiring": isHiring,
            "ownerId": currentUserId  // This must match the UID of the logged-in admin
        ]
        
        // Print the booth data for debugging
        print("Attempting to add booth with data: \(boothData)")
        
        // Attempt to set the data for the booth
        boothRef.setData(boothData) { error in
            if let error = error {
                print("Error adding booth: \(error.localizedDescription)")
            } else {
                print("Booth added successfully and linked to admin with UID: \(currentUserId)")
            }
        }
    }
}
