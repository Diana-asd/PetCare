//
//  PetCareApp.swift
//  PetCare
//
//  Created by Christian on 19/11/26.
//

import SwiftUI
import CoreData

@main
struct PetCareApp: App {
    let persistenceController = PersistenceController.shared
    @State private var mensaje: String?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RaizView()
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
                .onOpenURL { url in
                    importar(url)
                }
                .alert("PetCare",
                       isPresented: Binding(get: { mensaje != nil },
                                            set: { if !$0 { mensaje = nil } })) {
                    Button("Aceptar", role: .cancel) { }
                } message: {
                    Text(mensaje ?? "")
                }
        }
    }

    private func importar(_ url: URL) {
        guard url.pathExtension.lowercased() == "petcare" else { return }
        do {
            let mascota = try ImportadorMascota.importar(
                desde: url,
                en: persistenceController.container.viewContext)
            mensaje = "Se importó a \(mascota.nombre ?? "la mascota") con su historial."
        } catch let error as ErrorImportacion {
            mensaje = error.localizedDescription
        } catch {
            mensaje = "No se pudo leer el archivo. Verifica que sea una ficha de PetCare."
        }
    }
}
