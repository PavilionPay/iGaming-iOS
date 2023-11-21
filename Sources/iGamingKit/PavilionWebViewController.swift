//
//  PavilionWebViewController.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import UIKit
import WebKit
import LinkKit


public struct PavilionWebViewConfiguration {
    public let url: URL
    public let linkPresentationMethod: PresentationMethod?
    public let linkSuccess: LinkKit.OnSuccessHandler?
    public let linkEvent: LinkKit.OnEventHandler?
    public let linkExit: LinkKit.OnExitHandler?
    public let pavilionWebViewDidComplete: ((PavilionWebViewController) -> Void)?
    
    public init(url: URL, linkPresentationMethod: PresentationMethod? = nil, linkSuccess: LinkKit.OnSuccessHandler? = nil, linkEvent: LinkKit.OnEventHandler? = nil, linkExit: LinkKit.OnExitHandler? = nil, pavilionWebViewDidComplete: ( (PavilionWebViewController) -> Void)? = nil) {
        self.url = url
        self.linkPresentationMethod = linkPresentationMethod
        self.linkSuccess = linkSuccess
        self.linkEvent = linkEvent
        self.linkExit = linkExit
        self.pavilionWebViewDidComplete = pavilionWebViewDidComplete
    }
}

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
    
    public func loadPavilionSDK(with configuration: PavilionWebViewConfiguration) {
        self.configuration = configuration
        webView.load(URLRequest(url: configuration.url))
    }
    
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
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
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
    private var nativeBridgeJS: String {
        """
        window.addEventListener("message", function(e) {
            window?.webkit?.messageHandlers?.NativeBridge?.postMessage(e.data);
        });
        """
    }
    
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


extension WKScriptMessage {
    var linkToken: String? {
        guard name == "NativeBridge" else { return nil }
        return (body as? [String : String])?["linkToken"]
    }
    
    var isCloseMessage: Bool {
        guard name == "NativeBridge" else { return false }
        return (body as? String) == "close"
    }
}
