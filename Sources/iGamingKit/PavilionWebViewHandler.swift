//
//  PavilionWebViewHandler.swift
//
//  Created by Ben Ion on 7/11/24.
//

import Foundation
import WebKit
import LinkKit

public final class PavilionWebViewHandler: NSObject {
    private let pavilionConfig: PavilionWebViewConfiguration
    private var plaidLinkHandler: Handler?
    
    public init(pavilionConfig: PavilionWebViewConfiguration) {
        self.pavilionConfig = pavilionConfig
    }
    
    /// Returns a JavaScript string that adds a message event listener to the window.
    private let nativeBridgeJS = """
        window.addEventListener("message", function(e) {
            window?.webkit?.messageHandlers?.NativeBridge?.postMessage(e.data);
        });
        """
    
    public func setupWebview(_ webview: WKWebView) {
        webview.configuration.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "NativeBridge")
        webview.configuration.userContentController.addUserScript(
            WKUserScript(
                source: nativeBridgeJS,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            ))
    }
}

extension PavilionWebViewHandler: WKScriptMessageHandlerWithReply {
    /// Handles script messages received from the web content.
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        if let token = message.linkToken {
            var linkConfiguration = LinkTokenConfiguration(token: token) { [weak self] success in
                guard let self = self else { return }
                self.pavilionConfig.linkSuccess?(success)
                replyHandler(success.metadata.metadataJSON!, nil)
            }
            
            linkConfiguration.onExit = { [weak self] exit in
                guard let self = self else { return }
                replyHandler(exit.metadata, exit.error?.errorJSON)
            }
            
            linkConfiguration.onEvent = { [weak self] event in
                guard let self = self else { return }
                self.pavilionConfig.linkEvent?(event)
            }
            switch Plaid.create(linkConfiguration) {
            case .failure(let error):
                print("PavilionWebViewHandler: Unable to create Plaid handler due to: \(error)")
            case .success(let plaidLinkHandler):
                self.plaidLinkHandler = plaidLinkHandler
                plaidLinkHandler.open(presentUsing: self.pavilionConfig.linkPresentationMethod)
            }
            return
        }
        
        if message.isCloseMessage {
            pavilionConfig.pavilionWebViewDidComplete()
            return
        }
        
        if message.isRequestFullscreenPlaid {
            pavilionConfig.pavilionWebViewDidComplete()
            pavilionConfig.fullScreenRequested()
            return
        }
        
        replyHandler(nil, nil)
    }
}
