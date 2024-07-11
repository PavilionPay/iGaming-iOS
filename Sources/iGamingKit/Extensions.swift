//
//  PavilionWebViewConfiguration.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//


import Foundation
import WebKit


/// These extensions add convenience properties to WKScriptMessage to get the link token and check if the message is a close message.
extension WKScriptMessage {
    
    var linkToken: String? {
        guard name == "NativeBridge" else { return nil }
        return (body as? [String : String])?["linkToken"]
    }
    
    var isCloseMessage: Bool {
        guard name == "NativeBridge" else { return false }
        return (body as? String) == "close"
    }
    
    var isRequestFullscreenPlaid: Bool {
        guard name == "NativeBridge" else { return false }
        return (body as? String) == "opensdk"
    }
    
}
