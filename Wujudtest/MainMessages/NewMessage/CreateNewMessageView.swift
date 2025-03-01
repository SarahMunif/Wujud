//
//  CreateNewMessageView.swift
//  Wujudtest
//
//  Created by su on 27/02/2025.
//

import SwiftUI


class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init(){
        fetchAllUsers()
    }
    private func fetchAllUsers(){
        AdminManger.shared.firestore.collection("admins").getDocuments { documentsSnapshot, error in
            if let error = error{
                self.errorMessage = "faild ro fetch users: \(error)"
                print("faild ro fetch users: \(error)")
                return
            }
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
//                let user = ChatUser(data: data)
                
                
                self.users.append(.init(data: data))
            })
            
//            self.errorMessage = "test "
        }
    }
    
}

    
struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack{
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black, lineWidth:1)
                                )
                            Text(user.firstName)
                                .foregroundColor(Color(.label))
                            Spacer()
                            
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)


                }
                
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }

                    }
                }
        }

    }
}

#Preview {
    MainMessagesView()
}
