//
//  ChatLogView.swift
//  Wujudtest
//
//  Created by su on 28/02/2025.
//

import SwiftUI

import Firebase

class ChatLogViewModel: ObservableObject{
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        
        self.chatUser = chatUser
        
    }
    func handelSend(){
        print(chatText)
        guard let fromId = AuthenticationManger.shared.auth.currentUser?.uid else{ return }
        print("fromId: \(fromId)")
        
        guard let toId = chatUser?.uid else{ return }
        print("toId: \(toId)")

        let document =
        AdminManger.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId": fromId, "toId": toId, "text": self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into firebase \(error)"
                return
            }
        }
        
    }
}


struct ChatLogView: View{
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm : ChatLogViewModel
     
    var body: some View{
        
        VStack{
         messgesView
            Text(vm.errorMessage)
         chatBottomBar

        }

        .navigationTitle(chatUser?.username ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messgesView: some View{
        
            ScrollView{
                
                ForEach(0..<10) { num in
                    HStack{
                        Spacer()
                        HStack{
                            Text("fake message")
                                .foregroundColor(.white)

                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                HStack{ Spacer()}
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    private var chatBottomBar: some View
    {
        HStack (spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
//                TextEditor(text: $chatText)
            TextField("Description", text: $vm.chatText)
            
            Button {
                vm.handelSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical,8)
            .background(Color.blue)
            .cornerRadius(15)

        }
        .padding(.horizontal)
        .padding(.vertical,8)
    }
}
#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: ["uid" : "uAjk0j6s6nRBBC15WXz2C9whom73", "email" : "sadaia@gmail.om"]))
    }
}
