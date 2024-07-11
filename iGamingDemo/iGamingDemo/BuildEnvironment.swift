//  BuildEnvironment.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation
import os

struct BuildEnvironment: Codable {
    let secret: String
    let issuer: String
    let audience: String
    let sdkBaseUri: String
    let redirectUri: String
    
    static let shared: BuildEnvironment = {
        let path = Bundle.main.path(forResource: "BuildEnvironmentVariables", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        let config = try! PropertyListDecoder().decode(BuildEnvironment.self, from: data)
        
        config.log()
        return config
    }()
    
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
