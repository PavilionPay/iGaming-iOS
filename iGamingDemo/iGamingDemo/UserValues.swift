//  UserValues.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation

#warning("Replace values below with your own")

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
    static let secret = <#PAVILION_TOKEN_SECRET#>
    
    /// Pavilion issuer.
    ///
    /// Set to an empty string if using an externally generated token.
    static let issuer = <#PAVILION_TOKEN_ISSUER#>
    
    /// Pavilion audience.
    ///
    /// Set to an empty string if using an externally generated token.
    static let audience = <#PAVILION_TOKEN_AUDIENCE#>
    
    /// iGaming SDK Base URI.
    static let sdkBaseUri = <#PAVILION_BASE_URI#>
    
    /// Redirect URI.
    ///
    /// Plaid requires redirectUri a valid Universal Link and to be registered with Plaid.
    /// See Plaid Setup: https://plaid.com/docs/link/ios/#register-your-redirect-uri
    static let redirectUri = <#YOUR_REDIRECT_URI#>
}
