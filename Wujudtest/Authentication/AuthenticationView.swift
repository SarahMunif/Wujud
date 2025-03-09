import SwiftUI
import Firebase

struct AuthenticationView: View {
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0x0E / 255, green: 0x2A / 255, blue: 0x34 / 255),  // #0E2A34
                Color(red: 0x58 / 255, green: 0xC0 / 255, blue: 0x91 / 255),  // #58C091
                Color(red: 0x02 / 255, green: 0x10 / 255, blue: 0x24 / 255)   // #021024
            ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 60) {
                // Title at the top
                HStack {
                    Text("Sign up with wujud")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                
                // MARK: - Container
                VStack(spacing: 20) {
                    // Sign up as attendee button
                    NavigationLink {
                        SigninEmailView()
                    } label: {
                        Text("Sign up as an attendee")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.16, green: 0.24, blue: 0.28)) // Dark button color
                            .cornerRadius(25)
                    }
                    
                    // Sign up as booth admin button
                    NavigationLink {
                        SigninAdminView()
                    } label: {
                        Text("Sign up as a booth admin")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.16, green: 0.24, blue: 0.28))
                            .cornerRadius(25)
                    }
                    
                    // "have an account ? sign in"
                    NavigationLink {
                        SigninView(didCompleteLoginProcess: {})
                    } label: {
                        Text("have an account ? sign in")
                            .font(.callout)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                }
                .padding(.vertical, 120)
                .padding(.horizontal, 20)
                .background(Color(red: 0.35, green: 0.45, blue: 0.55).opacity(0.3))
                .cornerRadius(30)
                // Increase container size
                .frame(minWidth: 300, minHeight: 350)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        // Hides the default nav title (optional)
        .navigationTitle("")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
}
