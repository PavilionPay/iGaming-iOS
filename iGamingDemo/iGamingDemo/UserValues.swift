//  UserValues.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation
import os


/// User Values
///
/// This enum contains values related to the user and the Pavilion SDK.
///
/// - Warning: Replace these values with your own.
///
/// - Note: In your production application replace the values below with code that fetches a JWT
/// from your backend server which in turn retrieves it securely from Pavilion.
/// For more information, see [Pavilion's Documentation](https://ausenapccde03.azureedge.net/)
enum UserValues {
    
    /// JWT secret.
    ///
    /// Set to an empty string if using an externally generated token.
    static let secret = BuildEnvironment.shared.secret
    
    /// Pavilion issuer.
    ///
    /// Set to an empty string if using an externally generated token.
    static let issuer = BuildEnvironment.shared.issuer
    
    /// Pavilion audience.
    ///
    /// Set to an empty string if using an externally generated token.
    static let audience = BuildEnvironment.shared.audience
    
    /// iGaming SDK Base URI.
    static let sdkBaseUri = BuildEnvironment.shared.sdkBaseUri
    
    /// Redirect URI.
    ///
    /// Plaid requires redirectUri a valid Universal Link and to be registered with Plaid.
    /// See Plaid Setup: https://plaid.com/docs/link/ios/#register-your-redirect-uri
    static let redirectUri = BuildEnvironment.shared.redirectUri
    
}

struct BuildEnvironment: Codable {
    fileprivate let secret: String
    fileprivate let issuer: String
    fileprivate let audience: String
    fileprivate let sdkBaseUri: String
    fileprivate let redirectUri: String
    
    static let shared: BuildEnvironment = {
        BuildEnvironment.loadFromFile()
    }()
    
    fileprivate static func loadFromFile() -> BuildEnvironment {
        let path = Bundle.main.path(forResource: "BuildEnvironmentVariables", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        let config = try! PropertyListDecoder().decode(BuildEnvironment.self, from: data)
        
        config.log()
        return config
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case secret      = "Secret"
        case issuer      = "Issuer"
        case audience    = "Audience"
        case sdkBaseUri  = "BaseUri"
        case redirectUri = "RedirectUri"
    }
    
    func log() {
        os_log("secret: %{PUBLIC}@", log: .default, type: .default, secret)
        os_log("issuer: %{PUBLIC}@", log: .default, type: .default, issuer)
        os_log("audience: %{PUBLIC}@", log: .default, type: .default, audience)
        os_log("sdkBaseUri: %{PUBLIC}@", log: .default, type: .default, sdkBaseUri)
        os_log("redirectUri: %{PUBLIC}@", log: .default, type: .default, redirectUri)
    }
}
