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
        UINavigationController(rootViewController: SessionSetupViewController(nibName: "SessionSetupViewController", bundle: Bundle.main))
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}

#Preview {
    DemoView()
}
