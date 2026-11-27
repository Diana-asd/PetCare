//
//  RaizView.swift
//  PetCare
//
//  Created by Christian on 26/11/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct RaizView: View {
    @StateObject private var auth = AuthViewModel()
    @State private var mostrandoSplash = true

    var body: some View {
        ZStack {
            if let uid = auth.usuario?.uid {
                ContentView(uid: uid)
                    .id(uid)
            } else {
                AccesoView()
            }
            if mostrandoSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .environmentObject(auth)
        .task {
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeInOut(duration: 0.5)) {
                mostrandoSplash = false
            }
        }
    }
}
