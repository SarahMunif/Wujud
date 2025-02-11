//
//  AdminHomeView.swift
//  Wujudtest
//
//  Created by su on 09/02/2025.
//

import SwiftUI

struct AdminHomeView: View {
    var firstName: String
    var lastName: String

    var body: some View {
        Text("Hello \(firstName) \(lastName), welcome to the admin panel!")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    AdminHomeView(firstName: "Admin", lastName: "User")
}
