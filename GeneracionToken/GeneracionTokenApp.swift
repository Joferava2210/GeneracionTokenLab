//
//  GeneracionTokenApp.swift
//  GeneracionToken
//
//  Created by Felipe Ramirez Vargas on 26/3/21.
//

import SwiftUI
import Amplify
import AmplifyPlugins

@main
struct GeneracionTokenApp: App {
    init() {
        configureAmplify()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAmplify(){
        do {
            Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("An error ocurred setting up Amplify: \(error)")
        }
    }
}
