//
//  Mascota+Resumen.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//

import Foundation

extension Mascota {

    var edadTexto: String {
        guard let nac = fechaNac else { return "Edad desconocida" }
        let c = Calendar.current.dateComponents([.year, .month], from: nac, to: Date())
        let anios = c.year ?? 0
        let meses = c.month ?? 0
        switch (anios, meses) {
        case (0, let m): return m == 1 ? "1 mes" : "\(m) meses"
        case (let a, 0): return a == 1 ? "1 año" : "\(a) años"
        default: return "\(anios) \(anios == 1 ? "año" : "años") \(meses) \(meses == 1 ? "mes" : "meses")"
        }
    }

    var subtituloResumen: String {
        [especie, raza, sexo, edadTexto]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var vacunasOrdenadas: [Vacuna] {
        (vacunas as? Set<Vacuna> ?? [])
            .sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
    }

    /// La última dosis de cada vacuna, para saber qué refuerzos siguen pendientes.
    var vacunasVigentes: [Vacuna] {
        let agrupadas = Dictionary(grouping: vacunasOrdenadas) {
            ($0.nombre ?? "").lowercased()
        }
        return agrupadas.values
            .compactMap { $0.first }
            .sorted { ($0.proximaFecha ?? .distantFuture) < ($1.proximaFecha ?? .distantFuture) }
    }

    var desparasitacionesOrdenadas: [Desparasitacion] {
        (desparasitaciones as? Set<Desparasitacion> ?? [])
            .sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
    }

    var alergiasOrdenadas: [Alergia] {
        (alergias as? Set<Alergia> ?? [])
            .sorted { ($0.alergeno ?? "") < ($1.alergeno ?? "") }
    }

    var enfermedadesOrdenadas: [Enfermedad] {
        (enfermedades as? Set<Enfermedad> ?? [])
            .sorted { ($0.fechaInicio ?? .distantPast) > ($1.fechaInicio ?? .distantPast) }
    }

    var cirugiasOrdenadas: [Cirugia] {
        (cirugias as? Set<Cirugia> ?? [])
            .sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
    }

    var sintomasOrdenados: [Sintoma] {
        (sintomas as? Set<Sintoma> ?? [])
            .sorted { ($0.fecha ?? .distantPast) > ($1.fecha ?? .distantPast) }
    }
}
