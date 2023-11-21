//
//  ContentView.swift
//  iGamingKit
//
//  Created by Pavilion Payments
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DemoView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DemoView: UIViewControllerRepresentable {
    
    final class Coordinator: NSObject {
        private let parent: DemoView
        
        init(parent: DemoView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: ViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Empty implementation
    }
}
