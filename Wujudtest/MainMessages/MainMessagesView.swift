//
//  MainMessagesView.swift
//  Wujudtest
//
//  Created by su on 26/02/2025.
//

import SwiftUI


class MainMessagesViewModel: ObservableObject{
    
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    
    
    init(){
//        DispatchQueue.main.async {
//            self.isUserCurrentlyLoggedOut = true
//            AuthenticationManger.shared.auth.currentUser?.uid == nil
//            
//        }
        AuthenticationManger.shared.auth.currentUser?.uid == nil
        fetchCurrentUser()
    }
     func fetchCurrentUser(){
        guard let uid =
        AuthenticationManger.shared.auth.currentUser?.uid
        else{
            self.errorMessage = "could not find firebase uid "
            return}
        AdminManger.shared.firestore.collection("admins").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Faild to fetch \(error)"
                print("Faild to fetch ", error)
                return
            }
            guard let data = snapshot?.data() else{
                self.errorMessage = "No data found"
                return
            }
//            print(data)
//            self.errorMessage = "Data : \(data.description)"
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handelSignOut() {
        do {
            try AuthenticationManger.shared.auth.signOut()
            isUserCurrentlyLoggedOut = true
        } catch let signOutError {
            print("Failed to sign out: \(signOutError)")
        }
    }

}



struct MainMessagesView: View {
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
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

    
    private var customNavBar: some View {
        HStack{
            
            VStack(alignment: .leading, spacing: 4){
                Text("\(vm.chatUser?.username ?? "")")
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
                    vm.handelSignOut()
                }),
                .cancel()
            ])
    
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            SigninView(didCompleteLoginProcess:{
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
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
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View{
        Button {
            shouldShowNewMessageScreen.toggle()
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
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView()
        }
    }
    
    
}

#Preview {
    MainMessagesView()
}
