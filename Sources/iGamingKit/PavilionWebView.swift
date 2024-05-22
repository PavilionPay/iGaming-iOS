//
//  File.swift
//  
//
//  Created by Ben Ion on 5/22/24.
//

import UIKit
import WebKit
import LinkKit

public final class PavilionWebView: WKWebView {
    
    private var pavilionConfig: PavilionWebViewConfiguration!
    private var plaidLinkHandler: Handler!
    private var linkToken: String!
    private var linkCompletionReplyHandler: (Any?, String?) -> Void = { _, _ in }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(pavilionConfig: PavilionWebViewConfiguration ) {
        self.pavilionConfig = pavilionConfig 
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let wkPrefs = WKPreferences()
        wkPrefs.javaScriptCanOpenWindowsAutomatically = true
        
        super.init(frame: .zero, configuration: WKWebViewConfiguration()) 
        self.configuration.defaultWebpagePreferences = prefs
        self.configuration.preferences = wkPrefs
        self.configuration.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "NativeBridge")
        self.configuration.userContentController.addUserScript(
            WKUserScript(
                source: nativeBridgeJS,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            ))
        
        load(URLRequest(url: pavilionConfig.url))
    }
        
    /// Returns a JavaScript string that adds a message event listener to the window.
    private var nativeBridgeJS: String {
        """
        window.addEventListener("message", function(e) {
            window?.webkit?.messageHandlers?.NativeBridge?.postMessage(e.data);
        });
        """
    }
    
    deinit {
        let controller = configuration.userContentController
        controller.removeAllUserScripts()
        controller.removeScriptMessageHandler(forName: "NativeBridge", contentWorld: .page)
    }
}

extension PavilionWebView: WKScriptMessageHandlerWithReply {
    /// Handles script messages received from the web content.
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        if let token = message.linkToken {
            linkToken = token
            linkCompletionReplyHandler = replyHandler
            switch Plaid.create(createLinkTokenConfiguration()) {
            case .failure(let error):
                print("PavilionWebViewController: Unable to create Plaid handler due to: \(error)")
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
        
        replyHandler(nil, nil)
    }
    
    /// Creates a LinkTokenConfiguration for the Plaid SDK.
    private func createLinkTokenConfiguration() -> LinkTokenConfiguration {
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { [weak self] success in
            guard let self = self else { return }
            self.pavilionConfig.linkSuccess?(success)
            self.linkCompletionReplyHandler(success.metadata.metadataJSON!, nil)
        }
        
        linkConfiguration.onExit = { [weak self] exit in
            guard let self = self else { return }
            self.linkCompletionReplyHandler(exit.metadata, exit.error?.errorJSON)
        }
        
        linkConfiguration.onEvent = { [weak self] event in
            guard let self = self else { return }
            self.pavilionConfig.linkEvent?(event)
        }
        
        return linkConfiguration
    }
    
}
