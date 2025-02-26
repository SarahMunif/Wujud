//
//  MainMessagesView.swift
//  Wujudtest
//
//  Created by su on 26/02/2025.
//

import SwiftUI

struct MainMessagesView: View {
    @State var shouldShowLogOutOptions = false
    
    private var customNavBar: some View {
        HStack{
            VStack(alignment: .leading, spacing: 4){
                Text("Username")
                    .font(.system(size: 24, weight: .bold))
                HStack{
                    Circle()
                        .foregroundColor(Color(.green))
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
                
            }
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
                    

            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("settings"), message: Text("what do you want to do "), buttons: [
                .destructive(Text("Sign out"), action: {
                    print("handel sign out")
                }),
                .cancel()
            ])
    
        }
    }
    var body: some View {
        NavigationView {
            // nav bar
            VStack{
                customNavBar
                messagesView
           }
            .overlay(
 
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            }
    }
    private var messagesView : some View {
        ScrollView {
            ForEach(0..<10, id: \.self){num in
                VStack{
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black, lineWidth:1)
                            )
                        VStack(alignment: .leading){
                            Text("Username")
                            Text("Message sent to user")
                                .font(.system(size: 12))
                                .foregroundColor(Color(.lightGray))
                            
                        }
                        Spacer()
                        Text("22")
                            .font(.system(size:14, weight:.semibold))
                    }
                    Divider()
                        .padding(.vertical,8)
                    
                } .padding(.horizontal)
                
                
                
            }.padding(.bottom,50)
        }

    }
    private var newMessageButton: some View{
        Button {
            
        } label: {
            HStack{
                Spacer()
                Text("+ new message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
                .foregroundColor(Color.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(24)
                .padding(.horizontal)
                .shadow( radius: 15)
            
        }
    }
}

#Preview {
    MainMessagesView()
}
