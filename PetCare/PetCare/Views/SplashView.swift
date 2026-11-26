//
//  SplashView.swift
//  PetCare
//
//  Created by Christian on 26/11/26.
//

import Foundation
import SwiftUI

struct SplashView: View {
    @State private var aparecer = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.24, green: 0.78, blue: 0.79),
                                    Color(red: 0.04, green: 0.44, blue: 0.44)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(red: 0.06, green: 0.55, blue: 0.55))
                }
                Text("PetCare")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Eslogan")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .scaleEffect(aparecer ? 1 : 0.85)
            .opacity(aparecer ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                aparecer = true
            }
        }
    }
}

#Preview {
    SplashView()
}
