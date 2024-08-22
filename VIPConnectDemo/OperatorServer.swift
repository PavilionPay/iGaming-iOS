//
//  OperatorServer.swift
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

struct BuildEnvironment: Codable {
    let Secret: String
    let Issuer: String
    let Environment: String
    
    static let shared: BuildEnvironment = {
        let path = Bundle.main.path(forResource: "BuildEnvironmentVariables", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        return try! PropertyListDecoder().decode(BuildEnvironment.self, from: data)
    }()
}

/// Operator Server
///
/// This class is responsible for initializing a patron session and generating patron data.
///
/// - Note: You can provide the values above to generate a token locally, or provide a token from another source, such as an SDK backend here.
///
/// - Warning: Do not generate tokens locally in a production application. This can expose sensitive information and lead to security vulnerabilities. Always use a secure server-side process to generate tokens.
class OperatorServer {
    
    static let baseUrl = "https://\(BuildEnvironment.shared.Environment).api-gaming.paviliononline.io/sdk"
    
    /// Initializes a patron session for a given patron type, transaction type, and transaction amount.
    ///
    /// - Parameters:
    ///   - patronType: The type of the patron. This can be "new" or "existing".
    ///   - transactionType: The type of the transaction. This can be "deposit" or "withdraw".
    ///   - transactionAmount: The amount of the transaction.
    ///
    /// - Returns: A URL for the patron session, or `nil` if an error occurs.
    static func getPatronSession(transactionType: String) async throws -> String {
        
        if BuildEnvironment.shared.Environment.isEmpty {
            throw SessionCreationError.badToken("Build Environment variables not set; please update them with values for your operator provided by Pavilion.")
        }
        
        let patronData = OperatorServer.patronTransactionData(withAmount: "10.0", type: transactionType, productType: "0")
        
        let url = URL(string: "\(baseUrl)/api/patronsession/existing")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = patronData
        let token = TokenGenerator.generate()!
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = response as? HTTPURLResponse, res.statusCode >= 400 {
            throw SessionCreationError.badToken("Operator token invalid; please check Build Environment variables.")
        }
        
        let patron = try JSONDecoder().decode(PatronResponse.self, from: data)
        return patron.sessionId
    }
    
    static func createPatronSessionUrl(transactionType: String, sessionId: String) -> URL {
        return URL(string: "\(baseUrl)?mode=\(transactionType)#\(sessionId)")!
    }
    
}


/// Example Patron Data
///
/// This extension provides methods for generating patron data.
extension OperatorServer {
    
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
                patronID: "cb7c887d-6687-4aa5-a664-31cf6c810df7",
                vipCardNumber: "7210806973",
                dateOfBirth: "04/15/1980",
                remainingDailyDeposit: 999.99,
                walletBalance: 1000,
                transactionID: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
                transactionAmount: Double(amount)!,
                transactionType: type == "deposit" ? 0 : 1,
                returnURL: "closevip://done",
                productType: productType
            )
        )
    }
}

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

struct PatronResponse: Codable {
    let sessionId: String
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
        var iss = BuildEnvironment.shared.Issuer
        var aud = "vip-api-\(BuildEnvironment.shared.Environment)"
    }
    
    /// Generates a JWT token.
    ///
    /// - Returns: A JWT token, or `nil` if an error occurs.
    static func generate() -> String? {
        let now = Int(Date.now.timeIntervalSince1970)
        let payload = Payload(nbf: now - 300, exp: now + 1200, iat: now)
        
        let decoded = Data(base64Encoded: Data(BuildEnvironment.shared.Secret.utf8))!
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
