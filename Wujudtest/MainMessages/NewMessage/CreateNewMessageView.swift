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
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack{
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 55, height: 55)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50.0)
                                    .stroke(Color(.label),
                                        lineWidth: 2)
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
    CreateNewMessageView()
}
