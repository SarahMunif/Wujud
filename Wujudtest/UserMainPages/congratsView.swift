//
//  congratsView.swift
//  Wujudtest
//
//  Created by su on 09/03/2025.
//

import SwiftUI

struct congratsView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
            
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Congratulations!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    HStack {
                        Text("Welcome to ")
                            .font(.title)
                            .fontWeight(.bold)                            .foregroundColor(.white)
                        
                        Text("Wujud")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.green)  // Wujud in green color
                    }
                    Text("You’ve successfully completed registration form.\n We're excited to have you with us. Let’s make your conference experience unforgettable!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                    
                    // Continue Button
                    NavigationLink{
                        TutorialView()
                    }
                     label: {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 57/255, green: 120/255, blue: 101/255)) // #397865
                            .cornerRadius(25)
                            .padding(.top, 20)
                    }
                }
                .padding()
                .background(Color(red: 0.35, green: 0.45, blue: 0.55).opacity(0.3))
                .cornerRadius(30)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationTitle("")
    }
}

#Preview {
    congratsView()
}
