//
//  ExistingUserInfoView.swift
//  iGamingDemo
//
//  Created by Wright, James on 2/13/24.
//

import SwiftUI


fileprivate let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "MM/dd/yy"
    return fmt
}()

fileprivate struct ExistingUserData: Codable {
    var patronID: String
    var vipCardNumber: String
    var dateOfBirth: Date
    
    init(from user: ExistingUserSessionRequest) {
        self.patronID = user.patronID
        self.vipCardNumber = user.vipCardNumber
        self.dateOfBirth = dateFormatter.date(from: user.dateOfBirth) ?? Date()
    }
    
    init(patronID: String, vipCardNumber: String, dateOfBirth: String) {
        self.patronID = patronID
        self.vipCardNumber = vipCardNumber
        self.dateOfBirth = dateFormatter.date(from: dateOfBirth) ?? Date()
    }
}

fileprivate extension ExistingUserSessionRequest {
    mutating func update(from userData: ExistingUserData) {
        self.patronID = userData.patronID
        self.vipCardNumber = userData.vipCardNumber
        self.dateOfBirth = dateFormatter.string(from: userData.dateOfBirth)
    }
}


struct ExistingUserInfoView: View {
    @State private var existingUserData = ExistingUserData.init(from: OperatorServer.existingUserSessionRequest)

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Patron Identifier") {
                    TextField("Patron ID", text: $existingUserData.patronID)
                        .minimumScaleFactor(0.8)
                }
                Section("VIP Number") {
                    TextField("VIP Account Number", text: $existingUserData.vipCardNumber)
                }
                Section("Date of Birth") {
                    DatePicker("Date of Birth", selection: $existingUserData.dateOfBirth, displayedComponents: .date)
                }
            }
            .navigationTitle("Existing User Info")
            .navigationBarItems(leading: Button("Close") {
                // Handle back action
                self.presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                // Handle done action
                OperatorServer.existingUserSessionRequest.update(from: existingUserData)
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ExistingUserInfoView()
}
