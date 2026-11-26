//
//  FilaMascotaView.swift
//  PetCare
//
//  Created by Christian on 26/11/26.
//

import Foundation
import SwiftUI

struct FilaMascotaView: View {
    @ObservedObject var mascota: Mascota

    private var vencidas: Int {
        let hoy = Calendar.current.startOfDay(for: Date())
        return mascota.vacunasVigentes
            .filter { ($0.proximaFecha ?? .distantFuture) < hoy }
            .count
    }

    private var proximas: Int {
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: Date())
        guard let limite = calendario.date(byAdding: .day, value: 30, to: hoy) else { return 0 }
        return mascota.vacunasVigentes.filter { vacuna in
            guard let proxima = vacuna.proximaFecha else { return false }
            return proxima >= hoy && proxima <= limite
        }.count
    }

    private var subtitulo: String {
        [mascota.especie, mascota.edadTexto]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 14) {
            FotoMascotaView(data: mascota.foto, tamano: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text(mascota.nombre ?? "Sin nombre")
                    .font(.headline)
                Text(subtitulo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                estadoVacunas
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .tarjetaEstilo()
    }

    @ViewBuilder
    private var estadoVacunas: some View {
        if vencidas > 0 {
            etiqueta(vencidas == 1 ? "1 vacuna vencida" : "\(vencidas) vacunas vencidas",
                     color: .red, icono: "exclamationmark.circle.fill")
        } else if proximas > 0 {
            etiqueta("Refuerzo próximo", color: .orange, icono: "clock.fill")
        } else if !mascota.vacunasVigentes.isEmpty {
            etiqueta("Sin pendientes", color: .green, icono: "checkmark.circle.fill")
        }
    }

    private func etiqueta(_ texto: String, color: Color, icono: String) -> some View {
        Label(texto, systemImage: icono)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
    }
}
