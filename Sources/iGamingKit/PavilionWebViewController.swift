//
//  PavilionWebViewController.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import UIKit

// PavilionWebViewController class
// This class is a UIViewController that manages a WKWebView. It implements the WKScriptMessageHandlerWithReply protocol to handle messages from the web content.
public final class PavilionWebViewController: UIViewController {
    
    public var pavilionConfig: PavilionWebViewConfiguration!
    private var webView: PavilionWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView = PavilionWebView(pavilionConfig: pavilionConfig)
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
}
