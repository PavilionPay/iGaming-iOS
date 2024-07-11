//
//  UserInfoView.swift
//  iGamingDemo
//
//  Created by Wright, James on 1/25/24.
//

import SwiftUI

fileprivate let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "MM/dd/yy"
    return fmt
}()

fileprivate struct NewUserData: Codable {
    var firstName: String
    var middleInitial: String
    var lastName: String
    var dateOfBirth: Date
    var email: String
    var mobilePhone: String
    var streetName: String
    var city: String
    var state: String
    var zip: String
    var country: String
    var idType: String
    var idNumber: String
    var idState: String
    var routingNumber: String
    var accountNumber: String
    
    init(from newUserSessionRequest: NewUserSessionRequest) {
        self.firstName = newUserSessionRequest.firstName
        self.middleInitial = newUserSessionRequest.middleInitial
        self.lastName = newUserSessionRequest.lastName
        self.dateOfBirth = dateFormatter.date(from: newUserSessionRequest.dateOfBirth) ?? Date()
        self.email = newUserSessionRequest.email
        self.mobilePhone = newUserSessionRequest.mobilePhone
        self.streetName = newUserSessionRequest.streetName
        self.city = newUserSessionRequest.city
        self.state = newUserSessionRequest.state
        self.zip = newUserSessionRequest.zip
        self.country = newUserSessionRequest.country
        self.idType = newUserSessionRequest.idType
        self.idNumber = newUserSessionRequest.idNumber
        self.idState = newUserSessionRequest.idState
        self.routingNumber = newUserSessionRequest.routingNumber
        self.accountNumber = newUserSessionRequest.accountNumber
    }
    
    init(firstName: String, middleInitial: String, lastName: String, dateOfBirth: String, email: String, mobilePhone: String, streetName: String, city: String, state: String, zip: String, country: String, idType: String, idNumber: String, idState: String, routingNumber: String, accountNumber: String) {
        self.firstName = firstName
        self.middleInitial = middleInitial
        self.lastName = lastName
        self.dateOfBirth = dateFormatter.date(from: dateOfBirth) ?? Date()
        self.email = email
        self.mobilePhone = mobilePhone
        self.streetName = streetName
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.idType = idType
        self.idNumber = idNumber
        self.idState = idState
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
    }
}

fileprivate extension NewUserSessionRequest {
    mutating func update(from userData: NewUserData) {
        self.firstName = userData.firstName
        self.middleInitial = userData.middleInitial
        self.lastName = userData.lastName
        self.dateOfBirth = dateFormatter.string(from: userData.dateOfBirth)
        self.email = userData.email
        self.mobilePhone = userData.mobilePhone
        self.streetName = userData.streetName
        self.city = userData.city
        self.state = userData.state
        self.zip = userData.zip
        self.country = userData.country
        self.idType = userData.idType
        self.idNumber = userData.idNumber
        self.idState = userData.idState
        self.routingNumber = userData.routingNumber
        self.accountNumber = userData.accountNumber
    }
}

enum IdentificationType: String, CaseIterable, Identifiable {
    case driversLicense = "Drivers License"
    case passport = "Passport"
    case ssn = "SSN"
    case stateID = "State ID"
    case militaryID = "Military ID"
    
    var id: String { self.rawValue }
}

struct UserInfoView: View {
    @State private var newUserData = NewUserData.init(from: OperatorServer.newUserSessionRequest)
    @State private var selectedIDType = IdentificationType.driversLicense

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("First Name", text: $newUserData.firstName)
                    TextField("Middle Initial", text: $newUserData.middleInitial)
                    TextField("Last Name", text: $newUserData.lastName)
                }
                Section("Date of Birth") {
                    DatePicker("Date of Birth", selection: $newUserData.dateOfBirth, displayedComponents: .date)
                }
                Section("Contact") {
                    TextField("Email", text: $newUserData.email)
                    TextField("Mobile Phone", text: $newUserData.mobilePhone)
                    TextField("Street Name", text: $newUserData.streetName)
                    TextField("City", text: $newUserData.city)
                    TextField("State", text: $newUserData.state)
                    TextField("Zip", text: $newUserData.zip)
                    TextField("Country", text: $newUserData.country)
                }
                Section("Identification") {
                    Picker("ID Type", selection: $selectedIDType) {
                        ForEach(IdentificationType.allCases) { idType in
                            Text(idType.rawValue).tag(idType)
                        }
                    }
                    TextField("ID Number", text: $newUserData.idNumber)
                    if selectedIDType == .driversLicense || selectedIDType == .stateID {
                        TextField("ID State", text: $newUserData.idState)
                    }
                }
                Section("Banking") {
                    TextField("Routing Number", text: $newUserData.routingNumber)
                    TextField("Account Number", text: $newUserData.accountNumber)
                }
            }
            .navigationTitle("New User Info")
            .navigationBarItems(leading: Button("Close") {
                // Handle back action
                self.presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                // Handle done action
                OperatorServer.newUserSessionRequest.update(from: newUserData)
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        
    }
    

}

#Preview {
    UserInfoView()
}
