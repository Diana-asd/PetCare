//
//  ContentView.swift
//  PetCare
//
//  Created by Christian on 19/11/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mascota.nombre, ascending: true)],
        animation: .default)
    private var mascotas: FetchedResults<Mascota>

    @State private var mostrarFormulario = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(mascotas) { mascota in
                    NavigationLink {
                        DetalleMascotaView(mascota: mascota)
                    } label: {
                        HStack(spacing: 12) {
                            FotoMascotaView(data: mascota.foto, tamano: 52)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mascota.nombre ?? "Sin nombre")
                                    .font(.headline)
                                Text(mascota.especie ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: eliminar)
            }
            .overlay {
                if mascotas.isEmpty {
                    ContentUnavailableView("Sin mascotas",
                                           systemImage: "pawprint",
                                           description: Text("Toca + para agregar la primera"))
                }
            }
            .navigationTitle("Mis mascotas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { mostrarFormulario = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrarFormulario) {
                AgregarMascotaView()
            }
        }
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { mascotas[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
