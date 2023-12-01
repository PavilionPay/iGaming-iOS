# iGaming SDK for iOS

This repository contains a sample application that demonstrates integration and use of the iGaming SDK for iOS.

Detailed instructions on how to integrate with the iGaming SDK for iOS can be found in our [main documentation](https://ausenapccde03.azureedge.net/).

API Reference can be found [here](https://pavilionpay.github.io/iGaming-iOS/documentation/igamingkit/)

## About the iGamingDemo Xcode project

Before building and running the sample application replace any Xcode placeholder strings (like `<#YOUR_REDIRECT_URI#>`) in the code with the appropriate value so that the iGaming SDK is configured properly. For convenience the Xcode placeholder strings are also marked as compile-time warnings.


## Getting Started

Follow these steps to integrate the iGaming SDK into your iOS project:

Follow the steps outlined in the [Operator Setup](https://ausenapccde03.azureedge.net/operator-onboarding/operator-setup)


## Installation

Add a package dependency to your project or package at the following URL: `https://github.com/PavilionPay/iGaming-iOS`


## Usage

- Note: To view the steps to integrate and use the iGaming SDK in code, view the `ViewController.swift` file in the demo project.


1. Create an instance of `PavilionWebViewController` and present it.
```swift
let vc = PavilionWebViewController()
show(vc, sender: self)
```
2. Acquire an iGaming token securely from a backend service. This step is mocked in the code by calling the `initializePatronSession(forPatronType:transactionType:transactionAmount:)` method on `OperatorServer`, a mock service that generates or accepts a token and initializes an iGaming session using the provided patron and transaction information.
3. Configure a `PavilionWebViewConfiguration` object using the returned URL.
```swift
let configuration = PavilionWebViewConfiguration(url: url)
```
4. Load the iGaming SDK with Pavilion and Plaid configuration options by calling the `loadPavilionSDK(with:)` method on the `PavilionWebViewController` instance.
```swift
vc.loadPavilionSDK(with: configuration)
```


For more detailed information, refer to the following resources:

- [Plaid iOS SDK](https://plaid.com/docs/link/ios/)
- [Create Patron Session](https://ausenapccde03.azureedge.net/APIS/SDK/create-patron-session)
