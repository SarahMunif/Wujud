//
//  AdminTutorialView.swift
//  Wujudtest
//
//  Created by su on 27/03/2025.
//



import SwiftUI
import WebKit

struct AdminYouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1")!
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct AdminTutorialView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.green.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Start A Tutorial ?")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 300, height: 200)
                    .overlay(
                        AdminYouTubeView(videoID: "iqlH4okiQqg")
                            .frame(width: 280, height: 180)
                            .cornerRadius(10)
                    )
                
                HStack(spacing: 20) {
                    NavigationLink(destination: AdminHomePage()) {
                        Text("Skip")
                            .frame(width: 100, height: 40)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

#Preview {
    AdminTutorialView()
}
