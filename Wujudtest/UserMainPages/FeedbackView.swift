//
//  FeedbackView.swift
//  Wujudtest
//
//  Created by su on 27/03/2025.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var problem = ""
    @State private var isShowingMailView = false
    @State private var canSendMail = false // To check if the device can send email

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Get in Touch")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Text("You can reach us anytime")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                VStack(spacing: 10) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .keyboardType(.emailAddress)

                    TextEditor(text: $problem)
                        .padding()
                        .frame(height: 150)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .padding(.vertical, 5)

                }
                .padding(.horizontal)

                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        // Check if mail can be sent
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        } else {
                            // Handle error when email cannot be sent
                            print("Mail services are not available")
                        }
                    }) {
                        Text("Submit")
                            .frame(width: 120, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(firstName: firstName, lastName: lastName, email: email, problem: problem)
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    var firstName: String
    var lastName: String
    var email: String
    var problem: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["WujudApplication@outlook.com"])
        vc.setSubject("User Feedback")
        vc.setMessageBody("First Name: \(firstName)\nLast Name: \(lastName)\nEmail: \(email)\nProblem: \(problem)", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
#Preview {
    FeedbackView()
}
