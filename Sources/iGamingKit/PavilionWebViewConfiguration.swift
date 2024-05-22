//
//  PavilionWebViewConfiguration.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import Foundation
import LinkKit

/// `PavilionWebViewConfiguration` is a public structure that holds the configuration for the Pavilion web view.
///
/// It includes the following properties:
/// - `url`: The URL to load in the Pavilion web view.
/// - `linkPresentationMethod`: An optional `PresentationMethod` that defines how the Pavilion web view should be presented. `PresentationMethod` is defined in `LinkKit`.
/// - `linkSuccess`: An optional `LinkKit.OnSuccessHandler` that handles successful events from LinkKit.
/// For more information, see [Plaid's onSuccess Documentation](https://plaid.com/docs/link/ios/#onsuccess)
/// - `linkEvent`: An optional `LinkKit.OnEventHandler` that handles all events from LinkKit.
/// For more information, see [Plaid's onEvent Documentation](https://plaid.com/docs/link/ios/#onevent)
/// - `linkExit`: An optional `LinkKit.OnExitHandler` that handles exit events from LinkKit.
/// For more information, see [Plaid's onExit Documentation](https://plaid.com/docs/link/ios/#onexit)
/// - `pavilionWebViewDidComplete`: An optional closure that is called when the Pavilion web view completes its work. It takes a `PavilionWebViewController` as a parameter.
///
/// The `init(url:linkPresentationMethod:linkSuccess:linkEvent:linkExit:pavilionWebViewDidComplete:)` initializer allows you to create a `PavilionWebViewConfiguration` instance with all these properties.
public struct PavilionWebViewConfiguration {
    public let url: URL
    public let linkPresentationMethod: PresentationMethod
    public let pavilionWebViewDidComplete: () -> Void
    public let fullScreenRequested: () -> Void
    public let linkSuccess: LinkKit.OnSuccessHandler?
    public let linkEvent: LinkKit.OnEventHandler?
    public let linkExit: LinkKit.OnExitHandler?
    
    public init(url: URL, 
                linkPresentationMethod: PresentationMethod,
                pavilionWebViewDidComplete: @escaping () -> Void,
                fullScreenRequsted: @escaping () -> Void,
                linkSuccess: LinkKit.OnSuccessHandler? = nil,
                linkEvent: LinkKit.OnEventHandler? = nil,
                linkExit: LinkKit.OnExitHandler? = nil) {
        self.url = url
        self.linkPresentationMethod = linkPresentationMethod
        self.pavilionWebViewDidComplete = pavilionWebViewDidComplete
        self.fullScreenRequested = fullScreenRequsted
        self.linkSuccess = linkSuccess
        self.linkEvent = linkEvent
        self.linkExit = linkExit
        
    }
}
