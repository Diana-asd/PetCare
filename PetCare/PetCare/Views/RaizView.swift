//
//  RaizView.swift
//  PetCare
//
//  Created by Christian on 26/11/26.
//

import Foundation
import SwiftUI

struct RaizView: View {
    @State private var mostrandoSplash = true

    var body: some View {
        ZStack {
            ContentView()
            if mostrandoSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeInOut(duration: 0.5)) {
                mostrandoSplash = false
            }
        }
    }
}
