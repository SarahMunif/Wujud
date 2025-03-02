//
//  ChatLogView.swift
//  Wujudtest
//
//  Created by su on 28/02/2025.
//

import SwiftUI

import Firebase


struct FirebaseConstants{
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
}

struct ChatMessage : Identifiable{ //Identifiable so it can be iterated over
    
    var id: String { documentId } // an id sicne it is Identifiable
    
    let documentId: String
    let fromId, toId, text : String
    
    init(documentId: String, data: [String: Any]){
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.documentId = documentId
    }
    
}


class ChatLogViewModel: ObservableObject{
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        
        self.chatUser = chatUser
        
        fetchMessages()
        
    }
    
    private func fetchMessages(){
        guard let fromId = AuthenticationManger.shared.auth.currentUser?.uid else{ return }
        print("fromId: \(fromId)")
        
        guard let toId = chatUser?.uid else{ return }
        
         
        AdminManger.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "failed to listion : \(error)"
                    print (error)
                    return
                    
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added{
                       let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                }) // to preent showing dublicated messags
        
            }
        
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
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into firebase \(error)"
                return
            }
            print("successfuly saved current user sending message")
            self.chatText = ""

        }
        
        let recipientMessageDocument =
        AdminManger.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into firebase \(error)"
                return
            }
            
            print("Recipient saved message as well")

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
                
                ForEach(vm.chatMessages) { message in
                    
                    VStack{
                        if message.fromId == AuthenticationManger.shared.auth.currentUser?.uid {
                            HStack{
                                Spacer()
                                HStack{
                                    Text(message.text)
                                        .foregroundColor(.white)

                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                            }

                        }
                        else {
                            HStack{
                                HStack{
                                    Text(message.text)
                                        .foregroundColor(.black  )

                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                Spacer()
                            }
                        }
                        
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
