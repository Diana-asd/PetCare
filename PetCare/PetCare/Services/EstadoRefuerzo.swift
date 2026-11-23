//
//  EstadoRefuerzo.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI

struct EstadoRefuerzo {
    let texto: String
    let color: Color

    static func desde(_ proxima: Date?) -> EstadoRefuerzo? {
        guard let proxima else { return nil }
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: Date())
        let objetivo = calendario.startOfDay(for: proxima)
        let dias = calendario.dateComponents([.day], from: hoy, to: objetivo).day ?? 0
        if dias < 0 {
            return EstadoRefuerzo(texto: "Vencida hace \(-dias) d", color: .red)
        } else if dias <= 30 {
            return EstadoRefuerzo(texto: dias == 0 ? "Refuerzo hoy" : "Refuerzo en \(dias) d",
                                  color: .orange)
        } else {
            return EstadoRefuerzo(
                texto: "Próxima: \(proxima.formatted(date: .abbreviated, time: .omitted))",
                color: .green)
        }
    }
}
