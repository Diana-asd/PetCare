//
//  MascotaExportable.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//

import Foundation
import CoreData

struct MascotaExportable: Codable {
    static let versionActual = 1

    var version: Int = MascotaExportable.versionActual
    var nombre: String
    var especie: String
    var raza: String?
    var sexo: String?
    var fechaNac: Date?
    var notas: String?
    var foto: Data?
    var vacunas: [VacunaDTO]
    var desparasitaciones: [DesparasitacionDTO]
    var alergias: [AlergiaDTO]
    var enfermedades: [EnfermedadDTO]
    var cirugias: [CirugiaDTO]
    var sintomas: [SintomaDTO]

    struct VacunaDTO: Codable {
        var nombre: String
        var fecha: Date
        var proximaFecha: Date?
        var veterinario: String?
        var notas: String?
    }

    struct DesparasitacionDTO: Codable {
        var producto: String
        var tipo: String?
        var fecha: Date
        var proximaFecha: Date?
        var notas: String?
    }

    struct AlergiaDTO: Codable {
        var alergeno: String
        var reaccion: String?
        var fechaDeteccion: Date?
        var notas: String?
    }

    struct EnfermedadDTO: Codable {
        var nombre: String
        var fechaInicio: Date
        var estado: String
        var tratamiento: String?
        var notas: String?
    }

    struct CirugiaDTO: Codable {
        var nombre: String
        var gravedad: String
        var fecha: Date
        var veterinario: String?
        var notas: String?
    }

    struct SintomaDTO: Codable {
        var descripcion: String
        var fecha: Date
        var severidad: String?
        var notas: String?
    }

    init(_ m: Mascota) {
        nombre = m.nombre ?? "Sin nombre"
        especie = m.especie ?? "Otro"
        raza = m.raza
        sexo = m.sexo
        fechaNac = m.fechaNac
        notas = m.notas
        foto = m.foto
        vacunas = m.vacunasOrdenadas.map {
            VacunaDTO(nombre: $0.nombre ?? "", fecha: $0.fecha ?? Date(),
                      proximaFecha: $0.proximaFecha,
                      veterinario: $0.veterinario, notas: $0.notas)
        }
        desparasitaciones = m.desparasitacionesOrdenadas.map {
            DesparasitacionDTO(producto: $0.producto ?? "", tipo: $0.tipo,
                               fecha: $0.fecha ?? Date(),
                               proximaFecha: $0.proximaFecha, notas: $0.notas)
        }
        alergias = m.alergiasOrdenadas.map {
            AlergiaDTO(alergeno: $0.alergeno ?? "", reaccion: $0.reaccion,
                       fechaDeteccion: $0.fechaDeteccion, notas: $0.notas)
        }
        enfermedades = m.enfermedadesOrdenadas.map {
            EnfermedadDTO(nombre: $0.nombre ?? "",
                          fechaInicio: $0.fechaInicio ?? Date(),
                          estado: $0.estado ?? "Activa",
                          tratamiento: $0.tratamiento, notas: $0.notas)
        }
        cirugias = m.cirugiasOrdenadas.map {
            CirugiaDTO(nombre: $0.nombre ?? "", gravedad: $0.gravedad ?? "Menor",
                       fecha: $0.fecha ?? Date(),
                       veterinario: $0.veterinario, notas: $0.notas)
        }
        sintomas = m.sintomasOrdenados.map {
            SintomaDTO(descripcion: $0.descripcion ?? "", fecha: $0.fecha ?? Date(),
                       severidad: $0.severidad, notas: $0.notas)
        }
    }

    /// Guarda la ficha como archivo .petcare en la carpeta temporal.
    func escribirArchivo() -> URL? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let datos = try encoder.encode(self)
            let limpio = nombre
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(limpio).petcare")
            try datos.write(to: url, options: .atomic)
            return url
        } catch {
            print("Error al exportar la mascota: \(error)")
            return nil
        }
    }
}
