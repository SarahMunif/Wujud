import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore


@main
struct WujudtestApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
