//
//  Extensions.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation


// MARK: - Data

extension Data {
    /// A URL-safe, base64-encoded string representation of the data.
    ///
    /// This property replaces "+" with "-", "/" with "_", and removes "=".
    var urlSafeBase64EncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Creates a `Data` object from a base64-encoded string, adding padding automatically if needed.
    ///
    /// - Parameter encoded: The base64-encoded string.
    ///
    /// - Returns: A `Data` object, or `nil` if the string could not be decoded.
    public static func fromBase64(_ encoded: String) -> Data? {
        // Prefixes padding-character(s) (if needed).
        var encoded = encoded;
        let remainder = encoded.count % 4
        if remainder > 0 {
            encoded = encoded.padding(
                toLength: encoded.count + 4 - remainder,
                withPad: "=", startingAt: 0);
        }
        
        // Finally, decode.
        return Data(base64Encoded: encoded);
    }
    
    /// Prints the JSON representation of the data.
    ///
    /// If the data cannot be converted to a JSON object, this method prints an error message.
    func printJson() {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Inavlid data")
                return
            }
            print(jsonString)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
}


// MARK: - String

extension String {
    
    /// Creates a `String` from a base64-encoded string.
    ///
    /// - Parameter encoded: The base64-encoded string.
    ///
    /// - Returns: A `String`, or `nil` if the string could not be decoded.
    public static func fromBase64(_ encoded: String) -> String? {
        if let data = Data.fromBase64(encoded) {
            return String(data: data, encoding: .utf8)
        }
        return nil;
    }
    
}
