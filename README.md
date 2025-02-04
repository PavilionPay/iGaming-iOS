# VIP Connect SDK Integration for iOS

This repository contains a sample application that demonstrates integration and use of the VIP Connect SDK for iOS.

More instructions about the VIP Connect SDK can be found in our [main documentation](https://developer.vippreferred.com/).

## Integration Requirements

To interact with the VIP Connect services, first setup an [operator](https://developer.vippreferred.com/operator-onboarding/operator-setup) with Pavilion Payments.
This will allow you to create an [authentication token](https://developer.vippreferred.com/integration-steps/operator-requirements) for use with the Pavilion APIs
to [create a patron session](https://developer.vippreferred.com/APIS/SDK/create-patron-session) for your customer. 

After getting a session id, [launch the VIP SDK web component via URL](https://developer.vippreferred.com/integration-steps/invoke-web-component) inside
an [`ASWebAuthenticationSession`](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession). The `SessionSetupViewController`
class in this demo app demonstrates a simple way to do this.

VIP Connect uses [Finicity Connect WebSDK](https://developer.mastercard.com/open-banking-us/documentation/connect/integrating/webviews/android-webviews/) or [Plaid Hosted Link](https://plaid.com/docs/link/hosted-link/) to securely connect your customer\'s bank accounts with VIP Connect; launching
the VIP Connect SDK inside an `ASWebAuthenticationSession` is necessary to provide the best experience to your customers. 

## Returning to the app from VIP Connect

Upon completion or cancellation, VIP Connect will navigate to the address at the `returnURL` param passed during [session creation](https://developer.vippreferred.com/APIS/SDK/create-patron-session).
The sample app uses `closevip://done` as an example `returnURL`, which your app may use or modify as needed. 

## Running the sample app

This sample app is able to launch the VIP Connect flow as a demonstration, using mock data to create a real session on your operator.
However, you will need to provide the app with secret values obtained during [operator setup](https://developer.vippreferred.com/operator-onboarding/operator-setup)
so the app is able to authenticate against your operator.

The `BuildEnvironmentVariables.plist` file has fields for you to fill with your operator\'s values. You will need the JWT Secret and JWT Issuer fields
obtained during operator setup, and you will need to provide the name of the test environment your operator is in (such as `cert`). Please contact your
Pavilion Payments representative if you need help obtaining these values.

NOTE: While this sample app creates its JWT token locally and accesses VIP Mobility APIs directly, this is NOT a recommended practice for production apps!
Your app should not have access to your operator secrets, and should use a more secure method of obtaining a session id such as getting it from a backend
service that holds the secret values and acts as a middle layer between the app and VIP Connect's APIs.
