//
//  OperatorServer.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation
import CryptoKit


#warning("Replace values below with your own")
fileprivate let secret = <#YOUR_SDK_SECRET_HERE#>
fileprivate let issuer = <#PAVILION_ISSUER_HERE#>
fileprivate let audience = <#PAVILION_AUDIENCE_HERE#>
fileprivate let sdkBaseUrl = <#PAVILION_SDK_BASE_URL_HERE#>
fileprivate let redirectUrl = <#YOUR_REDIRECT_URL_HERE#>


// MARK: - Operator Server
class OperatorServer {
    
    // You can provide the values above to generate a token locally,
    // or provide a token from another source, such as an SDK backend here
    static var getExternalToken: (() -> String)? = nil
        
    //
    static func initializePatronSession(forPatronType patronType: String, transactionType: String, transactionAmount: String) async -> URL? {
        let patronData = patronType == "new"
        ? OperatorServer.newPatronTransactionData(withAmount: transactionAmount)
        : OperatorServer.patronTransactionData(withAmount: transactionAmount, type: transactionType)
        
        let url = URL(string: "\(sdkBaseUrl)/api/patronsession/\(patronType)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = patronData
        
        print(request.httpBody!.printJson())
        
        let token = getExternalToken?() ?? TokenGenerator.generate()!
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request.allHTTPHeaderFields!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            data.printJson()
            let patron = try JSONDecoder().decode(PatronResponse.self, from: data)
            print(response)
            let url = URL(string: "\(sdkBaseUrl)?mode=\(transactionType)&native=true&redirectUrl=\(redirectUrl)#\(patron.sessionId)")
            return url
        } catch {
            print(error)
        }
        
        return nil
    }
    
}

// MARK: - Example Patron Data
extension OperatorServer {
    
    static func newPatronTransactionData(withAmount amount: String) -> Data {
        try! JSONEncoder().encode(
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
                transactionAmount: Double(amount)!,
                returnURL: redirectUrl,
                productType: "preferred"
            )
        )
    }
    
    static func patronTransactionData(withAmount amount: String, type: String) -> Data {
        try! JSONEncoder().encode(
            ExistingUserSessionRequest(
                patronID: "cb7c887d-6687-4aa5-a664-31cf6c810df7",
                vipCardNumber: "7210645917",
                dateOfBirth: "5/28/1974",
                remainingDailyDeposit: 999.99,
                walletBalance: 1000,
                transactionID: String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)),
                transactionAmount: Double(amount)!,
                transactionType: type == "deposit" ? 0 : 1,
                returnURL: redirectUrl,
                productType: "preferred"
            )
        )
    }
}


// MARK: - Token Generator
fileprivate enum TokenGenerator {
    struct Header: Encodable {
        let typ = "JWT"
        let alg = "HS256"
    }
    
    struct Payload: Encodable {
        var nbf: Int
        var exp: Int
        var iat: Int
        var iss = issuer
        var aud = audience
    }
    
    
    static func generate() -> String? {
        let now = Int(Date.now.timeIntervalSince1970)
        let payload = Payload(nbf: now - 300, exp: now + 1200, iat: now)
        
        let decoded = Data(base64Encoded: Data(secret.utf8))!
        let privateKey = SymmetricKey(data: decoded)
        
        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString
        
        
        let payloadJSONData = try! JSONEncoder().encode(payload)
        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString
        
        let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)
        
        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString
        
        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        
        print("")
        return token
    }
}
