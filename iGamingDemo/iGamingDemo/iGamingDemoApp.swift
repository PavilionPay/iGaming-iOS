//
//  iGamingDemoApp.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import SwiftUI

@main
struct iGamingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoView()
        }
    }
}

struct DemoView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: SessionSetupViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Empty implementation
    }
}

#Preview {
    DemoView()
}
