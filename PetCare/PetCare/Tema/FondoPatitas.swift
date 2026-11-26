//
//  FondoPatitas.swift
//  PetCare
//
//  Created by Christian on 26/11/26.
//

import Foundation
import SwiftUI

private struct Huella: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let tamano: CGFloat
    let angulo: Double
    let opacidad: Double
}

/// Posiciones fijas (no cambian al redibujar la pantalla).
private let huellasDelFondo: [Huella] = {
    var semilla: UInt64 = 42
    func siguiente() -> Double {
        semilla = semilla &* 6364136223846793005 &+ 1442695040888963407
        return Double(semilla >> 33) / Double(1 << 31)
    }
    return (0..<34).map { i in
        Huella(id: i,
               x: siguiente(),
               y: siguiente(),
               tamano: 18 + siguiente() * 30,
               angulo: siguiente() * 360 - 180,
               opacidad: 0.05 + siguiente() * 0.09)
    }
}()

struct FondoPatitas: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            LinearGradient(colors: [Color.accentColor.opacity(0.18),
                                    Color.accentColor.opacity(0.04)],
                           startPoint: .top, endPoint: .bottom)
            GeometryReader { geo in
                ForEach(huellasDelFondo) { huella in
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: huella.tamano))
                        .rotationEffect(.degrees(huella.angulo))
                        .foregroundStyle(Color.accentColor.opacity(huella.opacidad))
                        .position(x: huella.x * geo.size.width,
                                  y: huella.y * geo.size.height)
                }
            }
        }
        .ignoresSafeArea()
    }
}
