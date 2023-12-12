//
//  ViewController.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import UIKit
import iGamingKit
import LinkKit // optional; required for presentation configuration


/// Demonstrates how to integrate and use the iGaming SDK.
class ViewController: UIViewController {
    
    /// This method is triggered when the open button is pressed.
    ///
    /// To launch an iGaming session:
    /// 1. Acquire an iGaming token securely from a backend service.
    ///  - Note: The token step is mocked here by calling the `initializePatronSession(forPatronType:transactionType:transactionAmount:)` method on `OperatorServer`, a mock service that generates or accepts a token and initializes an iGaming session using the provided patron and transaction information.
    /// 2. Configure a `PavilionWebViewConfiguration` object using the returned URL.
    /// 3. Create an instance of `PavilionWebViewController` and present it.
    /// 4. Load the iGaming SDK with Pavilion and Plaid configuration options by calling the `loadPavilionSDK(with:)` method on the `PavilionWebViewController` instance.
    ///
    /// If the `initializePatronSession(forPatronType:transactionType:transactionAmount:)` method returns `nil`, the method will trigger a fatal error, indicating that the Pavilion SDK could not be initialized.
    ///
    /// - Note: The `createPavilionConfiguration(with:)` method can be used to create a full configuration for the `PavilionWebViewController`, but in this case, a simple configuration is created using only the returned URL.
    @objc private func openButtonPressed() {
        showIndicator()
        
        Task {
            // Steps to launch an iGaming session:
            //
            // 1. Acquire an iGaming token securely from a backend service
            //      Ref - https://ausenapccde03.azureedge.net/integration-steps/operator-requirements
            // 2. Initialize an iGaming session
            //      Ref - https://ausenapccde03.azureedge.net/APIS/SDK/create-patron-session
            // 3. Configure a PavilionWebViewConfiguration object using the returned url and any optional presentation and Link callbacks
            // 4. Present the PavilionWebViewController
            
            // MARK: Acquire an iGaming token and initialize a session
            // 'OperatorServer' is a mock service that generates or accepts a token
            //      and then initializes an iGaming session using the provided
            //      patron and transaction information.
            //      Returns the SDK web component url after the session has been initialized.
            do {
                let url = try await OperatorServer.initializePatronSession(forPatronType: patronType, transactionType: transactionType, transactionAmount: transactionAmount)
                                
                // MARK: Create PavilionWebViewControllerConfiguration
                // Simplest case of creating configuration
                let configuration = PavilionWebViewConfiguration(url: url!)
                
                // MARK: Create a PavilionWebViewController instance and present it
                let vc = PavilionWebViewController()
                pavilionViewController = vc
                show(vc, sender: self)
                vc.loadViewIfNeeded()
                
                // MARK: Launch
                // Load the iGaming SDK with Pavilion and Plaid configuration options
                vc.loadPavilionSDK(with: configuration)
                
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
    
    /// This method creates a full configuration for a `PavilionWebViewController` instance.
    ///
    /// It takes a URL as input and returns a `PavilionWebViewConfiguration` object.
    ///
    /// The configuration includes:
    /// - The URL for the iGaming session.
    /// - A custom presentation method for the `PavilionWebViewController`. This method pushes the controller onto the navigation stack with a system background color, and pops it when it's done.
    /// - Handlers for the LinkKit success, event, and exit callbacks. These handlers simply print the relevant information to the console.
    /// - A completion handler for when the `PavilionWebViewController` finishes its work. This handler pops the controller from the navigation stack.
    ///
    /// This method demonstrates how to create a full configuration for the `PavilionWebViewController`, including how to handle various events and callbacks.
    private func createPavilionConfiguration(with url: URL) -> PavilionWebViewConfiguration {
        let nav = navigationController
        
        let presentationMethod = PresentationMethod.custom({ vc in
            vc.view.backgroundColor = .systemBackground
            nav?.pushViewController(vc, animated: true)
        }, { vc in
            nav?.popViewController(animated: true)
        })
        let success: LinkKit.OnSuccessHandler = { success in
            print("Link Success public-token: \(success.publicToken) metadata: \(success.metadata)")
        }
        let event: LinkKit.OnEventHandler = { event in
            print("Link Event: \(event)")
        }
        let exit: LinkKit.OnExitHandler = { exit in
            print("Link Exit with\n\t error: \(exit.error?.localizedDescription ?? "nil")\n\t metadata: \(exit.metadata)")
        }
        let didComplete = { (webView: PavilionWebViewController) -> Void in
            webView.navigationController?.popViewController(animated: true)
        }
        
        let configuration = PavilionWebViewConfiguration(
            url: url,
            linkPresentationMethod: presentationMethod,
            linkSuccess: success,
            linkEvent: event,
            linkExit: exit,
            pavilionWebViewDidComplete: didComplete
        )
        return configuration
    }
    
    
    private let vStack = UIStackView()
    private let welcomeLabel = UILabel()
    private let titleLabel = UILabel()
    private let openButton = UIButton()
    
    private let inputStack = UIStackView()
    private let transactionLabel = UILabel()
    private let transactionTypeLabel = UILabel()
    private let transactionTypeControl = UISegmentedControl(items: ["Deposit", "Withdraw"])
    private let patronTypeLabel = UILabel()
    private let patronTypeControl = UISegmentedControl(items: ["New", "Existing"])
    private let amountLabel = UILabel()
    private let amountInput = UITextField()
    private let spacerView = UIView()
    
    private let niceBlue = UIColor(red: 0.039, green: 0.522, blue: 0.918, alpha: 1.0)
    private let numberFormatter = NumberFormatter()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    
    // Pavilion Web View
    private var pavilionViewController: PavilionWebViewController?
    private var transactionType = "deposit"
    private var transactionAmount = "13.50"
    private var patronType = "existing"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideIndicator()
    }
}


extension ViewController: UITextFieldDelegate {
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupLabels()
        setupButton()
        setupInput()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupLabels() {
        welcomeLabel.numberOfLines = 1
        welcomeLabel.text = "WELCOME"
        welcomeLabel.font = .boldSystemFont(ofSize: 12)
        welcomeLabel.textColor = niceBlue
        
        titleLabel.numberOfLines = 0
        titleLabel.text = "iGaming SDK\nExample"
        titleLabel.font = .systemFont(ofSize: 32, weight: .light)
        
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.distribution = .fill
        vStack.addArrangedSubview(welcomeLabel)
        vStack.addArrangedSubview(titleLabel)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }
    
    private func setupButton() {
        openButton.backgroundColor = niceBlue
        openButton.addTarget(self, action: #selector(openButtonPressed), for: .touchUpInside)
        openButton.layer.cornerRadius = 8
        openButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        openButton.setTitle("Launch Pavilion Session", for: .normal)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(openButton)
        
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            openButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            openButton.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            openButton.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            openButton.heightAnchor.constraint(equalToConstant: 56),
            activityIndicator.centerXAnchor.constraint(equalTo: openButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: openButton.centerYAnchor)
        ])
    }
    
    private func showIndicator() {
        openButton.setTitle(nil, for: .normal)
        openButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    private func hideIndicator() {
        openButton.setTitle("Launch Pavilion Session", for: .normal)
        openButton.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
    
    private func setupInput() {
        numberFormatter.numberStyle = .decimal
        
        transactionLabel.text = "Transaction Details"
        transactionLabel.font = .systemFont(ofSize: 32, weight: .light)
        
        transactionTypeLabel.text = "TYPE"
        transactionTypeLabel.textColor = niceBlue
        transactionTypeLabel.textAlignment = .right
        transactionTypeLabel.font = .boldSystemFont(ofSize: 12)
        
        transactionTypeControl.selectedSegmentIndex = 0
        transactionTypeControl.translatesAutoresizingMaskIntoConstraints = false
        transactionTypeControl.addTarget(self, action: #selector(transactionTypeChanged), for: .valueChanged)
        
        patronTypeLabel.text = "USER"
        patronTypeLabel.textColor = niceBlue
        patronTypeLabel.textAlignment = .right
        patronTypeLabel.font = .boldSystemFont(ofSize: 12)
        
        patronTypeControl.selectedSegmentIndex = 1
        patronTypeControl.translatesAutoresizingMaskIntoConstraints = false
        patronTypeControl.addTarget(self, action: #selector(transactionTypeChanged), for: .valueChanged)
        
        amountLabel.text = "AMOUNT"
        amountLabel.textColor = niceBlue
        amountLabel.textAlignment = .right
        amountLabel.font = .boldSystemFont(ofSize: 12)
        
        amountInput.placeholder = "Transaction Amount ($)"
        amountInput.keyboardType = .numbersAndPunctuation
        amountInput.borderStyle = .roundedRect
        amountInput.backgroundColor = .systemGroupedBackground
        amountInput.delegate = self
        amountInput.translatesAutoresizingMaskIntoConstraints = false
        
        let patronStack = UIStackView(arrangedSubviews: [patronTypeLabel, patronTypeControl])
        let typeStack = UIStackView(arrangedSubviews: [transactionTypeLabel, transactionTypeControl])
        let amountStack = UIStackView(arrangedSubviews: [amountLabel, amountInput])
        patronStack.spacing = 8
        typeStack.spacing = 8
        amountStack.spacing = 8
        
        inputStack.axis = .vertical
        inputStack.spacing = 8
        inputStack.distribution = .fill
        inputStack.addArrangedSubview(transactionLabel)
        
        inputStack.addArrangedSubview(typeStack)
        inputStack.addArrangedSubview(amountStack)
        inputStack.addArrangedSubview(patronStack)
        
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
        vStack.addArrangedSubview(spacerView)
        vStack.addArrangedSubview(inputStack)
        
        NSLayoutConstraint.activate([
            spacerView.heightAnchor.constraint(equalToConstant: 40),
            amountLabel.widthAnchor.constraint(equalToConstant: 60),
            patronTypeLabel.widthAnchor.constraint(equalToConstant: 60),
            transactionTypeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty {
            return true
        }
        
        let components = updatedText.components(separatedBy: ".")
        if components.count == 2, components[1].count > 2 {
            return false
        }
        
        let number = numberFormatter.number(from: updatedText)
        transactionAmount = number?.stringValue ?? "13.50"
        return number != nil
    }
    
    @objc func transactionTypeChanged(_ sender: UISegmentedControl) {
        if sender == transactionTypeControl {
            transactionType = (sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "").lowercased()
        }
        if sender == patronTypeControl {
            patronType = (sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "").lowercased()
        }
    }
}
