//
//  ImportadorMascota.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//
import Foundation
import CoreData
import FirebaseAuth

enum ErrorImportacion: LocalizedError {
    case versionNueva

    var errorDescription: String? {
        switch self {
        case .versionNueva:
            return "Este archivo viene de una versión más nueva de PetCare. Actualiza la app para abrirlo."
        }
    }
}

enum ImportadorMascota {

    /// Importa un archivo .petcare como una mascota nueva de la cuenta actual.
    @discardableResult
    static func importar(desde url: URL, en contexto: NSManagedObjectContext) throws -> Mascota {
        let accede = url.startAccessingSecurityScopedResource()
        defer { if accede { url.stopAccessingSecurityScopedResource() } }

        let datos = try Data(contentsOf: url)
        let dto = try decodificar(datos)
        let mascota = crear(desde: dto, id: nil,
                            propietarioUID: Auth.auth().currentUser?.uid,
                            en: contexto)
        do {
            try contexto.save()
        } catch {
            contexto.rollback()
            throw error
        }
        return mascota
    }

    static func decodificar(_ datos: Data) throws -> MascotaExportable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dto = try decoder.decode(MascotaExportable.self, from: datos)
        guard dto.version <= MascotaExportable.versionActual else {
            throw ErrorImportacion.versionNueva
        }
        return dto
    }

    /// Crea la mascota y su historial en el contexto (sin guardar).
    static func crear(desde dto: MascotaExportable,
                      id: UUID?,
                      propietarioUID: String?,
                      en contexto: NSManagedObjectContext) -> Mascota {
        let mascota = Mascota(context: contexto)
        mascota.id = id ?? UUID()
        mascota.propietarioUID = propietarioUID
        mascota.nombre = dto.nombre
        mascota.especie = dto.especie
        mascota.raza = dto.raza
        mascota.sexo = dto.sexo
        mascota.fechaNac = dto.fechaNac
        mascota.notas = dto.notas
        mascota.foto = dto.foto

        for v in dto.vacunas {
            let vacuna = Vacuna(context: contexto)
            vacuna.id = UUID()
            vacuna.nombre = v.nombre
            vacuna.fecha = v.fecha
            vacuna.proximaFecha = v.proximaFecha
            vacuna.veterinario = v.veterinario
            vacuna.notas = v.notas
            vacuna.mascota = mascota
        }

        for d in dto.desparasitaciones {
            let registro = Desparasitacion(context: contexto)
            registro.id = UUID()
            registro.producto = d.producto
            registro.tipo = d.tipo
            registro.fecha = d.fecha
            registro.proximaFecha = d.proximaFecha
            registro.notas = d.notas
            registro.mascota = mascota
        }

        for a in dto.alergias {
            let alergia = Alergia(context: contexto)
            alergia.id = UUID()
            alergia.alergeno = a.alergeno
            alergia.reaccion = a.reaccion
            alergia.fechaDeteccion = a.fechaDeteccion
            alergia.notas = a.notas
            alergia.mascota = mascota
        }

        for e in dto.enfermedades {
            let enfermedad = Enfermedad(context: contexto)
            enfermedad.id = UUID()
            enfermedad.nombre = e.nombre
            enfermedad.fechaInicio = e.fechaInicio
            enfermedad.estado = e.estado
            enfermedad.tratamiento = e.tratamiento
            enfermedad.notas = e.notas
            enfermedad.mascota = mascota
        }

        for c in dto.cirugias {
            let cirugia = Cirugia(context: contexto)
            cirugia.id = UUID()
            cirugia.nombre = c.nombre
            cirugia.gravedad = c.gravedad
            cirugia.fecha = c.fecha
            cirugia.veterinario = c.veterinario
            cirugia.notas = c.notas
            cirugia.mascota = mascota
        }

        for s in dto.sintomas {
            let sintoma = Sintoma(context: contexto)
            sintoma.id = UUID()
            sintoma.descripcion = s.descripcion
            sintoma.fecha = s.fecha
            sintoma.severidad = s.severidad
            sintoma.notas = s.notas
            sintoma.mascota = mascota
        }

        return mascota
    }
}
