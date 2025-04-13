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
    static let email = "email"
    static let uid = "uid"
    
}

struct ChatMessage : Identifiable{ //Identifiable so it can be iterated over
    
    var id: String { documentId } // an id sicne it is Identifiable
    
    let documentId: String
    let fromId, toId, text , email , uid: String
    
    init(documentId: String, data: [String: Any]){
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.documentId = documentId
    }
    
}
/// /// //// /////////// ////////////////
class ChatLogViewModel: ObservableObject{
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    @Published var chatUser: ChatUser?

    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        fetchMessages()
        
    }
    
     func fetchMessages(){
        guard let fromId = AuthenticationManger.shared.auth.currentUser?.uid else{ return }
//        print("fromId: \(fromId)")
        
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
                }) // to prevent showing dublicated messags
                
                DispatchQueue.main.async {
                    self.count += 1
                    
                }
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
          
            self.persistRecentMessage()

            self.chatText = ""
            self.count += 1
            
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
    
  private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        guard let uid = AuthenticationManger.shared.auth.currentUser?.uid else { return }
        let toId = chatUser.uid

        // Save recent message for the sender
        let senderData: [String: Any] = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": uid,
            "toId": toId,
            "firstName": chatUser.firstName, // Recipient's info for sender's record
            "lastName": chatUser.lastName,
            "username": chatUser.username
        ]

        AdminManger.shared.firestore.collection("recent_messages")
            .document(uid).collection("messages").document(toId)
            .setData(senderData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message: \(error)"
                    print("Failed to save recent message: \(error)")
                    return
                }
            }

        // Determine the current sender's details.
        // Use the admin manager if available; otherwise, fall back to the user manager.
        guard let currentSender = AdminManger.shared.currentUser ?? UserManger.shared.currentUser else {
            print("No current user found in either manager")
            return
        }

        // Derive username from the authenticated user's email if needed.
        let senderUsername = AuthenticationManger.shared.auth.currentUser?.email?.components(separatedBy: "@").first ?? ""

        // Data for the recipient's recent message (using the sender's details)
        let recipientData: [String: Any] = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": uid,
            "toId": toId,
            "firstName": currentSender.firstName,
            "lastName": currentSender.lastName,
            "username": senderUsername
        ]

        AdminManger.shared.firestore.collection("recent_messages")
            .document(toId).collection("messages").document(uid)
            .setData(recipientData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recipient recent message: \(error)"
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }


    @Published var count = 0
}


struct ChatLogView: View{
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm : ChatLogViewModel
     
    var body: some View{
        ZStack{
        
            VStack{
                messgesView
                Text(vm.errorMessage)
                chatBottomBar
                
            }
        }

        .navigationTitle(chatUser?.username ?? "")
            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarItems(trailing: Button(action: {
//                vm.count += 1
//                
//            }, label: {
//                Text("count: \(vm.count)")
//            }))
    }
    
    static let emptyScollToString = "Empty"
    
    private var messgesView: some View{
        
            ScrollView{
                ScrollViewReader{ ScrollViewProxy in
                    VStack{
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message)

                        }
                        HStack{ Spacer()}
                            .id(ChatLogView.emptyScollToString)
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            ScrollViewProxy.scrollTo(ChatLogView.emptyScollToString, anchor: .bottom)

                        }
                    }
                
                }
 
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    private var chatBottomBar: some View
    {
        HStack (spacing: 16){
//            Image(systemName: "paperclip")
//                .font(.system(size: 24))
//                .foregroundColor(Color(.darkGray))
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
            .background(Color.green)
            .cornerRadius(15)

        }
        .padding(.horizontal)
        .padding(.vertical,8)
    }
}

struct MessageView: View{
    
    let message : ChatMessage
    
    var body: some View {
        VStack{
            if message.fromId == AuthenticationManger.shared.auth.currentUser?.uid {
                HStack{
                    Spacer()
                    HStack{
                        Text(message.text)
                            .foregroundColor(.white)

                    }
                    .padding()
                    .background(Color.green)
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
}

#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: ["uid" : "uAjk0j6s6nRBBC15WXz2C9whom73", "email" : "sadaia@gmail.om"]))
    }
}
