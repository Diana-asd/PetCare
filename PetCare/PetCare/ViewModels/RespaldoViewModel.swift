//
//  RespaldoViewModel.swift
//  PetCare
//
//  Created by Christian on 27/11/26.
//

import Foundation
import Combine
import CoreData

@MainActor
final class RespaldoViewModel: ObservableObject {
    @Published var trabajando = false
    @Published var mensaje: String?
    @Published var esError = false

    private var operacionActual = UUID()

    func respaldar(uid: String, contexto: NSManagedObjectContext) {
        ejecutar {
            let n = try await RespaldoService.respaldar(uid: uid, contexto: contexto)
            switch n {
            case 0: return "No tienes mascotas para respaldar."
            case 1: return "Se respaldó 1 mascota."
            default: return "Se respaldaron \(n) mascotas."
            }
        }
    }

    func restaurar(uid: String, contexto: NSManagedObjectContext) {
        ejecutar {
            let n = try await RespaldoService.restaurar(uid: uid, contexto: contexto)
            switch n {
            case 0: return "No hay mascotas nuevas para restaurar: este teléfono ya tiene todo lo que está en la nube."
            case 1: return "Se restauró 1 mascota."
            default: return "Se restauraron \(n) mascotas."
            }
        }
    }

    private func ejecutar(_ trabajo: @escaping () async throws -> String) {
        let id = UUID()
        operacionActual = id
        trabajando = true
        mensaje = nil

        Task {
            do {
                let texto = try await trabajo()
                guard operacionActual == id else { return }
                esError = false
                mensaje = texto
            } catch {
                print("Error de respaldo: \(error)")
                guard operacionActual == id else { return }
                esError = true
                mensaje = "No se pudo completar. Revisa tu conexión e inténtalo de nuevo."
            }
            if operacionActual == id { trabajando = false }
        }

        Task {
            try? await Task.sleep(for: .seconds(25))
            if operacionActual == id && trabajando {
                operacionActual = UUID()
                trabajando = false
                esError = true
                mensaje = "La operación tardó demasiado. Revisa tu conexión a internet."
            }
        }
    }
}
