//
//  Models.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation

// MARK: - Existing User
struct ExistingUserSessionRequest: Codable {
    var patronID: String
    var vipCardNumber: String
    var dateOfBirth: String
    var remainingDailyDeposit: Double
    var walletBalance: Double
    var transactionID: String
    var transactionAmount: Double
    var transactionType: Double
    var returnURL: String
    var productType: String
}

// MARK: - New User
struct NewUserSessionRequest: Codable {
    var patronId: String
    var firstName: String
    var middleInitial: String
    var lastName: String
    var dateOfBirth: String
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
    var walletBalance: String
    var remainingDailyDeposit: String
    var transactionId: String
    var transactionAmount: Double
    var returnURL: String
    var productType: String
}

// MARK: - Patron
struct PatronResponse: Codable {
    let sessionId: String
}

extension NewUserSessionRequest {
    static let userDefaultsKey = "NewUserSessionRequest"
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: NewUserSessionRequest.userDefaultsKey)
        }
    }
    
    static func readFromUserDefaults() -> NewUserSessionRequest? {
        if let savedData = UserDefaults.standard.object(forKey: NewUserSessionRequest.userDefaultsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(NewUserSessionRequest.self, from: savedData) {
                return loadedData
            }
        }
        return nil
    }
    
    static var exampleUser: NewUserSessionRequest {
        NewUserSessionRequest(
            patronId: UUID().uuidString,
            firstName: "Jane",
            middleInitial: "",
            lastName: "Public",
            dateOfBirth: "01/22/1981",
            email: "Jane@Jane.com",
            mobilePhone: "3023492104",
            streetName: "1301 E Main ST",
            city: "Carbondale",
            state: "IL",
            zip: "62901",
            country: "USA",
            idType: "DL",
            idNumber: "7774213035",
            idState: "IL",
            routingNumber: "",
            accountNumber: "",
            walletBalance: "1000",
            remainingDailyDeposit: "1000",
            transactionId: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
            transactionAmount: 10.33,
            returnURL: UserValues.redirectUri,
            productType: "preferred"
        )
    }
}


extension ExistingUserSessionRequest {
    static let userDefaultsKey = "ExistingUserSessionRequest"
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: ExistingUserSessionRequest.userDefaultsKey)
        }
    }
    
    static func readFromUserDefaults() -> ExistingUserSessionRequest? {
        if let savedData = UserDefaults.standard.object(forKey: ExistingUserSessionRequest.userDefaultsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(ExistingUserSessionRequest.self, from: savedData) {
                return loadedData
            }
        }
        return nil
    }
    
    static var exampleUser: ExistingUserSessionRequest {
        ExistingUserSessionRequest(
            patronID: "cb7c887d-6687-4aa5-a664-31cf6c810df7",
            vipCardNumber: "7210806973",
            dateOfBirth: "04/15/1980",
            remainingDailyDeposit: 999.99,
            walletBalance: 1000,
            transactionID: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
            transactionAmount: 10.33,
            transactionType: 0,
            returnURL: UserValues.redirectUri,
            productType: "preferred"
        )
    }
}
