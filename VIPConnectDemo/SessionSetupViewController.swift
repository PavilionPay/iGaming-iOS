//
//  SessionSetupViewController.swift
//
//  Created by Pavilion Payments
//

import UIKit
import AuthenticationServices

/// Demonstrates how to integrate and use the VIP Connect SDK.
class SessionSetupViewController: UIViewController {
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var launchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideIndicator()
    }
    
    @IBAction func launchVipSDK() {
        Task {
            // Steps to launch a VIP Connect session:
            //
            // 1. Initialize an VIP Connect session from a backend service
            // 2. Present the ASWebAuthenticationSession with the SDK url, passing the session id as a parameter
            
            do {
                let transactionType = "deposit" //can be "deposit" or "withdraw"
                
                showIndicator()
                let sessionId = try await OperatorServer.getPatronSession(transactionType: transactionType)
                hideIndicator()
                
                let url = OperatorServer.createPatronSessionUrl(transactionType: transactionType, sessionId: sessionId)
                
                // The callbackURLScheme should match the url sent as the `returnUrl` param during session creation,
                // and can be set by the operator at will.
                // This sample app uses the return url "closevip://done"; your app is free to use the same value or any
                // other you prefer.
                let vc = ASWebAuthenticationSession(url: url, callbackURLScheme: "closevip") { url, error in
                    if let e = error as? ASWebAuthenticationSessionError, e.code == ASWebAuthenticationSessionError.canceledLogin {
                        // session was cancelled by user, but transaction may still have completed successfully if the user cancelled
                        // the session after the transaction was complete.
                        return
                    }
                    
                    if url?.absoluteString.contains("done") == true {
                        // transaction completed successfully, and the session was automatically dismissed.
                        print("Successful transaction")
                    }
                }
                vc.presentationContextProvider = self
                vc.start()
            } catch {
                let alert = UIAlertController(title: "Error Initializing Sesion", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    alert.dismiss(animated: true)
                }))
                hideIndicator()
                present(alert, animated: true)
            }
        }
    }
    
    private func showIndicator() {
        launchButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    private func hideIndicator() {
        launchButton.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
}

extension SessionSetupViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
