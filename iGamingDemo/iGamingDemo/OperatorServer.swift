//
//  OperatorServer.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation
import CryptoKit

enum SessionCreationError: LocalizedError {
    case badToken(String)
    
    public var errorDescription: String? {
        switch self {
        case .badToken(let errorString): return errorString
        }
    }
}

/// Operator Server
///
/// This class is responsible for initializing a patron session and generating patron data.
///
/// - Note: You can provide the values above to generate a token locally, or provide a token from another source, such as an SDK backend here.
///
/// - Warning: Do not generate tokens locally in a production application. This can expose sensitive information and lead to security vulnerabilities. Always use a secure server-side process to generate tokens.
class OperatorServer {
    
    /// A closure that returns an external token.
    static var externalToken: String? = nil
    static var currentSession: String? = nil
    
    static var newUserSessionRequest: NewUserSessionRequest {
        get { NewUserSessionRequest.readFromUserDefaults() ?? .exampleUser }
        set { newValue.saveToUserDefaults() }
    }
    
    static var existingUserSessionRequest: ExistingUserSessionRequest {
        get { ExistingUserSessionRequest.readFromUserDefaults() ?? .exampleUser }
        set { newValue.saveToUserDefaults() }
    }
    
    /// Initializes a patron session for a given patron type, transaction type, and transaction amount.
    ///
    /// - Parameters:
    ///   - patronType: The type of the patron. This can be "new" or "existing".
    ///   - transactionType: The type of the transaction. This can be "deposit" or "withdraw".
    ///   - transactionAmount: The amount of the transaction.
    ///
    /// - Returns: A URL for the patron session, or `nil` if an error occurs.
    static func initializePatronSession(forPatronType patronType: String,
                                        transactionType: String,
                                        transactionAmount: String,
                                        productType: String,
                                        cashierMode: Bool) async throws -> URL? {
        let product = productType == "preferred" ? "0" : "1"
        let patronData = patronType == "new"
        ? OperatorServer.newPatronTransactionData(withAmount: transactionAmount, productType: product)
        : OperatorServer.patronTransactionData(withAmount: transactionAmount, type: transactionType, productType: product)
        
        let url = URL(string: "\(BuildEnvironment.shared.sdkBaseUri)/api/patronsession/\(patronType)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = patronData

        if let s = String(data: patronData, encoding: .utf8) {
            print(s)
        }
        
        let token = externalToken ?? TokenGenerator.generate()!
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request.allHTTPHeaderFields!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "nil")

        if let res = response as? HTTPURLResponse, res.statusCode >= 400 {
            throw SessionCreationError.badToken("Operator token invalid; please check")
        }
        let patron = try JSONDecoder().decode(PatronResponse.self, from: data)
        print(response)
        currentSession = patron.sessionId
        return createPatronSessionUrl(transactionType: transactionType, sessionId: currentSession, cashierMode: cashierMode)
    }
    
    static func createPatronSessionUrl(transactionType: String, sessionId: String? = currentSession, cashierMode: Bool = false) -> URL {
        let result = URL(string: "\(BuildEnvironment.shared.sdkBaseUri)?mode=\(transactionType)\(cashierMode ? "&view=cashier" : "&native=true")#\(currentSession!)")
        print(result!.absoluteString)
        return result!
    }
    
}


/// Example Patron Data
///
/// This extension provides methods for generating patron data.
extension OperatorServer {
    
    /// Generates data for a new patron transaction.
    ///
    /// - Parameter amount: The amount of the transaction.
    ///
    /// - Returns: A `Data` object containing the encoded patron data.
    static func newPatronTransactionData(withAmount amount: String, productType: String) -> Data {
        try! JSONEncoder().encode(
            NewUserSessionRequest(
                patronId: UUID().uuidString,
                firstName: newUserSessionRequest.firstName,
                middleInitial: newUserSessionRequest.middleInitial,
                lastName: newUserSessionRequest.lastName,
                dateOfBirth: newUserSessionRequest.dateOfBirth,
                email: newUserSessionRequest.email,
                mobilePhone: newUserSessionRequest.mobilePhone,
                streetName: newUserSessionRequest.streetName,
                city: newUserSessionRequest.city,
                state: newUserSessionRequest.state,
                zip: newUserSessionRequest.zip,
                country: newUserSessionRequest.country,
                idType: newUserSessionRequest.idType,
                idNumber: newUserSessionRequest.idNumber,
                idState: newUserSessionRequest.idState,
                routingNumber: newUserSessionRequest.routingNumber,
                accountNumber: newUserSessionRequest.accountNumber,
                walletBalance: newUserSessionRequest.walletBalance,
                remainingDailyDeposit: newUserSessionRequest.remainingDailyDeposit,
                transactionId: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
                transactionAmount: Double(amount)!,
                returnURL: BuildEnvironment.shared.redirectUri,
                productType: productType
            )
        )
    }
    
    /// Generates data for an existing patron transaction.
    ///
    /// - Parameters:
    ///   - amount: The amount of the transaction.
    ///   - type: The type of the transaction.
    ///
    /// - Returns: A `Data` object containing the encoded patron data.
    static func patronTransactionData(withAmount amount: String, type: String, productType: String) -> Data {
        try! JSONEncoder().encode(
            ExistingUserSessionRequest(
                patronID: existingUserSessionRequest.patronID,
                vipCardNumber: existingUserSessionRequest.vipCardNumber,
                dateOfBirth: existingUserSessionRequest.dateOfBirth,
                remainingDailyDeposit: 999.99,
                walletBalance: 1000,
                transactionID: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
                transactionAmount: Double(amount)!,
                transactionType: type == "deposit" ? 0 : 1,
                returnURL: BuildEnvironment.shared.redirectUri,
                productType: productType
            )
        )
    }
}


/// Token Generator
///
/// This enum provides a method for generating a JWT token.
fileprivate enum TokenGenerator {
    struct Header: Encodable {
        let typ = "JWT"
        let alg = "HS256"
    }
    
    struct Payload: Encodable {
        var nbf: Int
        var exp: Int
        var iat: Int
        var iss = BuildEnvironment.shared.issuer
        var aud = BuildEnvironment.shared.audience
    }
    
    /// Generates a JWT token.
    ///
    /// - Returns: A JWT token, or `nil` if an error occurs.
    static func generate() -> String? {
        let now = Int(Date.now.timeIntervalSince1970)
        let payload = Payload(nbf: now - 300, exp: now + 1200, iat: now)
        
        let decoded = Data(base64Encoded: Data(BuildEnvironment.shared.secret.utf8))!
        let privateKey = SymmetricKey(data: decoded)
        
        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = urlSafeBase64EncodedString(headerJSONData)
        
        let payloadJSONData = try! JSONEncoder().encode(payload)
        let payloadBase64String = urlSafeBase64EncodedString(payloadJSONData)
        
        let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)
        
        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = urlSafeBase64EncodedString(Data(signature))
        
        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        
        print("")
        return token
    }
    
    static func urlSafeBase64EncodedString(_ data: Data) -> String {
        return  data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
