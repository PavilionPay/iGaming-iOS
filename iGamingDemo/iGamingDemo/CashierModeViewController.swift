//
//  CashierModeViewController.swift
//  iGamingDemo
//
//  Created by Ben Ion on 5/22/24.
//

import UIKit
import iGamingKit

public final class CashierModeViewController: UIViewController {
    
    public var pavilionConfig: PavilionWebViewConfiguration!
    @IBOutlet private var webView: PavilionWebView!
    
    @IBAction func dismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.startWebview(pavilionConfig: pavilionConfig)
    }
}

