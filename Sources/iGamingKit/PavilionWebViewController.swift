//
//  PavilionWebViewController.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import UIKit
import WebKit
import LinkKit

// PavilionWebViewController class
// This class is a UIViewController that manages a WKWebView. It implements the WKScriptMessageHandlerWithReply protocol to handle messages from the web content.

public final class PavilionWebViewController: UIViewController, WKScriptMessageHandlerWithReply {
    
    private var configuration: PavilionWebViewConfiguration!
    
    private var webView: WKWebView!
    private var handler: Handler!
    private var linkToken: String!
    private var linkCompletionReplyHandler: (Any?, String?) -> Void = { _, _ in }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
    }
    
    
    /// Loads the Pavilion SDK with the given configuration.
    ///
    /// This method sets the configuration for the Pavilion web view and loads the URL from the configuration into the web view.
    ///
    /// - Parameter configuration: The configuration for the Pavilion web view. This includes the URL to load in the web view.
    ///
    /// # Example
    /// ```
    /// let url = URL(string: "https://www.example.com")!
    /// let configuration = PavilionWebViewConfiguration(url: url)
    /// loadPavilionSDK(with: configuration)
    /// ```
    public func loadPavilionSDK(with configuration: PavilionWebViewConfiguration) {
        self.configuration = configuration
        webView.load(URLRequest(url: configuration.url))
    }
    
    
    /// Handles script messages received from the web content.
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        if let token = message.linkToken {
            linkToken = token
            linkCompletionReplyHandler = replyHandler
            openLink()
            return
        }
        
        if message.isCloseMessage {
            closeWebView()
            return
        }
        
        replyHandler(nil, nil)
    }
    
    /// Sets up the web view with the appropriate configuration.
    private func setupWebView() {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let wkPrefs = WKPreferences()
        wkPrefs.javaScriptCanOpenWindowsAutomatically = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.preferences = wkPrefs
        config.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "NativeBridge")
        config.userContentController.addUserScript(
            WKUserScript(
                source: nativeBridgeJS,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            ))
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.bounces = false
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            webView.widthAnchor.constraint(equalTo: view.widthAnchor),
            webView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
    }
    
    deinit {
        let controller = webView.configuration.userContentController
        controller.removeAllUserScripts()
        controller.removeScriptMessageHandler(forName: "NativeBridge", contentWorld: .page)
    }
    
    /// Opens a link using the Plaid SDK.
    private func openLink() {
        let configuration = createLinkTokenConfiguration()
        
        let result = Plaid.create(configuration)
        switch result {
        case .failure(let error):
            print("PavilionWebViewController: Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            self.handler = handler
            let method = self.configuration.linkPresentationMethod ?? .custom({ vc in
                vc.view.backgroundColor = .systemBackground
                self.present(vc, animated: true)
            })
            handler.open(presentUsing: method)
        }
    }
    
    /// Creates a LinkTokenConfiguration for the Plaid SDK.
    private func createLinkTokenConfiguration() -> LinkTokenConfiguration {
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { [weak self] success in
            guard let self = self else { return }
            self.configuration.linkSuccess?(success)
            self.linkCompletionReplyHandler(success.metadata.metadataJSON!, nil)
        }
        
        linkConfiguration.onExit = { [weak self] exit in
            guard let self = self else { return }
            self.linkCompletionReplyHandler(exit.metadata, exit.error?.errorJSON)
        }
        
        linkConfiguration.onEvent = { [weak self] event in
            guard let self = self else { return }
            self.configuration.linkEvent?(event)
        }
        
        return linkConfiguration
    }
    
    
}


extension PavilionWebViewController {
    
    /// Returns a JavaScript string that adds a message event listener to the window.
    private var nativeBridgeJS: String {
        """
        window.addEventListener("message", function(e) {
            window?.webkit?.messageHandlers?.NativeBridge?.postMessage(e.data);
        });
        """
    }
    
    /// Closes the web view using the configured handler or a default implementation
    private func closeWebView() {
        if let dismissHandler = configuration.pavilionWebViewDidComplete {
            dismissHandler(self)
        } else {
            if let vc = presentingViewController {
                vc.dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
}


