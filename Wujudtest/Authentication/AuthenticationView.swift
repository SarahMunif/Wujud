import SwiftUI
import Firebase

struct AuthenticationView: View {
    var body: some View {
        VStack {
            NavigationLink {
                SigninEmailView()
            } label: {
                Text("Register as Attendee")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            NavigationLink {
                SigninAdminView()
            } label: {
                Text("Register as Booth Admin")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            NavigationLink {
                SigninView(didCompleteLoginProcess: {
                    
                })
            } label: {
                Text("Have an account? Sign in")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
        }
        .padding()
        .navigationTitle("Sign in")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
}
