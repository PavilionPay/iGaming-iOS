//
//  Models.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation

// MARK: - Existing User
struct ExistingUserSessionRequest: Codable {
    let patronID: String
    let vipCardNumber: String
    let dateOfBirth: String
    let remainingDailyDeposit: Double
    let walletBalance: Double
    let transactionID: String
    let transactionAmount: Double
    let transactionType: Double
    let returnURL: String
    let productType: String
}

// MARK: - New User
struct NewUserSessionRequest: Codable {
    let patronId: String
    let firstName: String
    let middleInitial: String
    let lastName: String
    let dateOfBirth: String
    let email: String
    let mobilePhone: String
    let streetName: String
    let city: String
    let state: String
    let zip: String
    let country: String
    let idType: String
    let idNumber: String
    let idState: String
    let routingNumber: String
    let accountNumber: String
    let walletBalance: String
    let remainingDailyDeposit: String
    let transactionId: String
    let transactionAmount: Double
    let returnURL: String
    let productType: String
}



// MARK: - Patron
struct PatronResponse: Codable {
    let sessionId: String
    let expires: String
    let enrollmentStatus: String
    let enrollmentStatusCode: Int
    let vipCardNumber: String?
    let operatorName: String
    let toggles: Toggles
    let transactionSucceeded: Bool
    let depositLimit: Double
    let minDeposit: Double
    let withdrawLimit: Double
    let minWithdraw: Double
    let transactionId: String
    let transactionAmount: Double
    let returnURL: String?
    let threatMetrixEnabled: Bool
    let threatMetrixContinueOnFail: Bool
    let threatMetrixOrgId: String
    let showTermsAndConditions: Bool
    let cultureCode: String
    let errorModel: ErrorModel?
}

// MARK: - Toggles
struct Toggles: Codable {
    let plaidEnabled: Bool
    let limitEnabled: Bool
    let showDashboardButtonAfterSuccess: Bool
    let manageFundingSourcesInDropdown: Bool
    let showTransactionConfirmation: Bool
    let identificationInfoEnabled: Bool
    let plaidDefault: Bool
    let mitekEnabled: Bool
}

// MARK: - Error
struct ErrorModel: Codable {
    let errorCode: String
    let transactionStage: String
    let operatorErrorMessage: String
    let operatorDeclineDescription: String
    let patronErrorMessage: String
}
