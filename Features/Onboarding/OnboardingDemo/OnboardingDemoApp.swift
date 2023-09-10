//
//  OnboardingDemoApp.swift
//  OnboardingDemo
//
//  Created by Albert Bori on 9/9/23.
//

import OnboardingMockConfig
import SwiftUI

@main
struct OnboardingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingMockFeature().getUnauthenticatedView()
        }
    }
}
