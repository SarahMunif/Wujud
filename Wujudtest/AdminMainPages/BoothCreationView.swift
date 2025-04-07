//
//  AddBoothView.swift
//  Wujudtest
//
//  Created by su on 09/03/2025.
//
import SwiftUI
import FirebaseAuth

struct BoothCreationView: View {
    @State private var companyName: String = ""
    @State private var description: String = ""
    @State private var industry: String = ""
    @State private var region: String = ""
    @State private var size: String = ""
    @State private var seeksInvestment: Bool = false
    @State private var offersTraining: Bool = false
    @State private var isHiring: Bool = false
    
    @State private var navigateToHome = false // State variable for navigation

    var body: some View {
        NavigationView {
            ZStack {
                // Apply the LinearGradient background to the entire screen
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
                
                VStack {
                    // Title and the rest of the UI
                    Text("start creat a booth ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Booth creation form
                    VStack(spacing: 20) {
                        TextField("Company Name", text: $companyName)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        TextField("Description", text: $description)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        TextField("Industry", text: $industry)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        TextField("Region", text: $region)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        TextField("Size for eg mid size , start up,..", text: $size)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        
                        Toggle(isOn: $seeksInvestment) {
                            Text("Seeks Investment")
                                .foregroundColor(.white)
                        }
                        
                        Toggle(isOn: $offersTraining) {
                            Text("Offers Training")
                                .foregroundColor(.white)
                        }
                        
                        Toggle(isOn: $isHiring) {
                            Text("Is Hiring")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        createBooth() // Create the booth and navigate
                        navigateToHome = true // Trigger navigation to home page
                    }) {
                        Text("Create Booth")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                    .disabled(!isFormValid())
                    
                    // NavigationLink to HomePageView after booth is created
                    NavigationLink(destination: AdminHomePage(), isActive: $navigateToHome) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func createBooth() {
        BoothManager.shared.createBooth(
            companyName: companyName,
            description: description,
            industry: industry,
            region: region,
            size: size,
            seeksInvestment: seeksInvestment,
            offersTraining: offersTraining,
            isHiring: isHiring
        )
    }
    
    private func isFormValid() -> Bool {
        !companyName.isEmpty && !description.isEmpty && !industry.isEmpty && !region.isEmpty && !size.isEmpty
    }
}

#Preview {
    BoothCreationView()
}
