//
//  RespaldoServices.swift
//  PetCare
//
//  Created by Christian on 27/11/26.
//

import Foundation
import CoreData
import FirebaseFirestore

@MainActor
enum RespaldoService {

    private static func coleccion(_ uid: String) -> CollectionReference {
        Firestore.firestore()
            .collection("usuarios").document(uid)
            .collection("mascotas")
    }

    /// Sube (o actualiza) cada mascota de la cuenta como un documento.
    static func respaldar(uid: String, contexto: NSManagedObjectContext) async throws -> Int {
        let peticion: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        peticion.predicate = NSPredicate(format: "propietarioUID == %@", uid)
        let mascotas = try contexto.fetch(peticion)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        var total = 0
        for mascota in mascotas {
            guard let id = mascota.id else { continue }
            let datos = try encoder.encode(MascotaExportable(mascota))
            guard let json = String(data: datos, encoding: .utf8) else { continue }
            try await coleccion(uid).document(id.uuidString).setData([
                "nombre": mascota.nombre ?? "",
                "datos": json,
                "actualizado": FieldValue.serverTimestamp()
            ])
            total += 1
        }
        return total
    }

    /// Trae de la nube las mascotas que este teléfono todavía no tiene.
    static func restaurar(uid: String, contexto: NSManagedObjectContext) async throws -> Int {
        let instantanea = try await coleccion(uid).getDocuments(source: .server)
        var total = 0
        for documento in instantanea.documents {
            guard let id = UUID(uuidString: documento.documentID),
                  let json = documento.data()["datos"] as? String,
                  let datos = json.data(using: .utf8),
                  let dto = try? ImportadorMascota.decodificar(datos) else { continue }

            let existente: NSFetchRequest<Mascota> = Mascota.fetchRequest()
            existente.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            existente.fetchLimit = 1
            if try contexto.fetch(existente).first != nil { continue }

            _ = ImportadorMascota.crear(desde: dto, id: id, propietarioUID: uid, en: contexto)
            total += 1
        }
        if contexto.hasChanges { try contexto.save() }
        return total
    }

    /// Borra la copia en la nube (se envía cuando haya conexión).
    static func eliminarEnNube(uid: String, id: UUID) {
        coleccion(uid).document(id.uuidString).delete()
    }
}
