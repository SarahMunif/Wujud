//
//  AddBoothView.swift
//  Wujudtest
//
//  Created by su on 09/03/2025.
//
import SwiftUI
import FirebaseAuth

struct AddBoothView: View {
    @State private var companyName: String = ""
    @State private var description: String = ""
    @State private var industry: String = ""
    @State private var region: String = ""
    @State private var size: String = ""
    @State private var seeksInvestment: Bool = false
    @State private var offersTraining: Bool = false
    @State private var isHiring: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Booth Information")) {
                    TextField("Company Name", text: $companyName)
                    TextField("Description", text: $description)
                    TextField("Industry", text: $industry)
                    TextField("Region", text: $region)
                    TextField("Size", text: $size)
                    
                    Toggle(isOn: $seeksInvestment) {
                        Text("Seeks Investment")
                    }
                    
                    Toggle(isOn: $offersTraining) {
                        Text("Offers Training")
                    }
                    
                    Toggle(isOn: $isHiring) {
                        Text("Is Hiring")
                    }
                }
                
                Section {
                    Button("Create Booth") {
                        createBooth()
                    }
                    .disabled(!isFormValid())
                }
            }
            .navigationBarTitle("Add Booth")
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

struct AddBoothView_Previews: PreviewProvider {
    static var previews: some View {
        AddBoothView()
    }
}


#Preview {
    AddBoothView()
}
