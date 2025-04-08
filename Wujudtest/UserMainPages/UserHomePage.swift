//
//  UserHomePage.swift
//  Wujudtest
//
//  Created by su on 27/03/2025.
//

import SwiftUI

struct UserHomePage: View {
    @State private var selectedTab = 2 // Default selected tab (Home)

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Page Tab
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Today's Conference")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Image("leap") // Ensure this image is in Assets.xcassets
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                        
                        Text("LEAP")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Label("Feb 1 - 17 Feb", systemImage: "calendar")
                                .foregroundColor(.white)
                            Spacer()
                            Label("10 am - 6 pm", systemImage: "clock")
                                .foregroundColor(.white)
                        }
                        .font(.subheadline)
                        
                        Text("LEAP is a premier global tech conference in Riyadh, uniting innovators, investors, and tech giants to shape the future of AI, robotics, and digital transformation.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        
                        
                        NavigationLink{
//                           BoothCreationView()
                        }
                         label: {
                             Text("Attend")
                              
                                 .padding()
                                 .frame(maxWidth: .infinity)
                            
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .background(Color.green)
                                 .cornerRadius(10)
                        }

                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(2)

            // Admin Profile Tab
            UserProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)

            // Main Messages Tab
            MainMessagesView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .tag(1)
            
            FeedbackView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill") // You can choose another appropriate icon
                    Text("Feedback")
                }
                .tag(4)
        }
    }
}


#Preview {
    UserHomePage()
}
