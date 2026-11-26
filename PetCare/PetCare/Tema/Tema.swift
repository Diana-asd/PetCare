//
//  Tema.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//

import Foundation
import SwiftUI

enum Tema {
    static let radioTarjeta: CGFloat = 20

    /// Cada categoría del historial tiene su propio color.
    enum Categoria {
        case vacunas, desparasitaciones, alergias, enfermedades, cirugias, sintomas

        var color: Color {
            switch self {
            case .vacunas: return .blue
            case .desparasitaciones: return .green
            case .alergias: return .orange
            case .enfermedades: return .red
            case .cirugias: return .purple
            case .sintomas: return .pink
            }
        }
    }
}

/// Cuadro redondeado con un ícono de color.
struct InsigniaIcono: View {
    let sistema: String
    let color: Color

    var body: some View {
        Image(systemName: sistema)
            .font(.title3.weight(.semibold))
            .foregroundStyle(color)
            .frame(width: 44, height: 44)
            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    /// Estilo de tarjeta que se adapta a modo claro y oscuro.
    func tarjetaEstilo() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: Tema.radioTarjeta))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    /// Fondo de la app para listas y formularios.
    func fondoLista() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background { FondoPatitas() }
    }
}
