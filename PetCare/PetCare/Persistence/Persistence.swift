//
//  Persistence.swift
//  PetCare
//
//  Created by Christian on 19/11/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let contexto = result.container.viewContext
        let ejemplo = Mascota(context: contexto)
        ejemplo.id = UUID()
        ejemplo.nombre = "Firulais"
        ejemplo.especie = "Perro"
        ejemplo.sexo = "Macho"
        try? contexto.save()
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PetCare")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error cargando Core Data: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
