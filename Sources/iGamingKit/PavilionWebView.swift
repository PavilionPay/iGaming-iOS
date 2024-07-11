//
//  PavilionWebView.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import UIKit
import WebKit
import LinkKit

public final class PavilionWebView: WKWebView {
    
    private var pavilionConfig: PavilionWebViewConfiguration!
    private var webviewHandler: PavilionWebViewHandler?
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(pavilionConfig: PavilionWebViewConfiguration) {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        startWebview(pavilionConfig: pavilionConfig)
    }
        
    public func startWebview(pavilionConfig: PavilionWebViewConfiguration) {
        self.pavilionConfig = pavilionConfig
        
        self.uiDelegate = self
        
        self.configuration.defaultWebpagePreferences = {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            return prefs
        }()
        
        self.configuration.preferences = {
            let wkPrefs = WKPreferences()
            wkPrefs.javaScriptCanOpenWindowsAutomatically = true
            return wkPrefs
        }()

        webviewHandler = PavilionWebViewHandler(pavilionConfig: pavilionConfig)
        webviewHandler?.setupWebview(self)
        
        load(URLRequest(url: pavilionConfig.url))
    }
}

extension PavilionWebView: WKUIDelegate {
    /**
     Delegte method that must be handled to open Chase OAuth UIs.
     See https://plaid.com/docs/link/oauth/#webview
     */
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("Attempting to open new window for \(navigationAction.request.url!)")
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        // Open the external URL in Safari
        UIApplication.shared.open(url)
        return nil
    }
}
