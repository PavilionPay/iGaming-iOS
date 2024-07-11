//
//  InjectIntoWebviewController.swift
//  iGamingDemo
//
//  Created by Ben Ion on 7/11/24.
//

import Foundation
import UIKit
import iGamingKit
import WebKit

/**
 An example of how to setup a WKWebView for the VIP SDK without using the PavilionWebViewController class.
 Your app might use this method if you cannot use a PavilionWebViewController, possibly because you need to
 use your own custom view controller or webview instead.
 */
class InjectIntoWebviewController: UIViewController {
    public var pavilionConfig: PavilionWebViewConfiguration!
    private var webView: WKWebView!
    private var webviewHandler: PavilionWebViewHandler?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        
        /// These settings are required for the VIP SDK to function correctly
        webView.configuration.defaultWebpagePreferences = {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            return prefs
        }()
        webviewHandler = PavilionWebViewHandler(pavilionConfig: pavilionConfig)
        webviewHandler?.setupWebview(webView)
        
        /// Other settings are optional and can be configured to the needs of your app
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
        
        webView.loadHTMLString("""
<body style="background:linear-gradient(90deg, rgba(154,152,191,1) 0%, rgba(9,109,121,1) 30%, rgba(0,212,255,1) 100%)">
<iframe
sandbox="allow-downloads allow-forms allow-modals allow-popups allow-same-origin allow-scripts"
  id="vipsdk"
  title="Inside iFrame"
  width="800"
  height="1500"
  src="\(pavilionConfig.url)">
</iframe>
</body>
""", baseURL: nil)
    }
}
