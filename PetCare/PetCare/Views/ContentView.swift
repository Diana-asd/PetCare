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
    @State private var mascotaAEliminar: Mascota?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(mascotas) { mascota in
                        NavigationLink {
                            DetalleMascotaView(mascota: mascota)
                        } label: {
                            FilaMascotaView(mascota: mascota)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                mascotaAEliminar = mascota
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
            .background { FondoPatitas() }
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
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $mostrarFormulario) {
                AgregarMascotaView()
            }
            .confirmationDialog(
                "¿Eliminar a \(mascotaAEliminar?.nombre ?? "esta mascota")?",
                isPresented: Binding(get: { mascotaAEliminar != nil },
                                     set: { if !$0 { mascotaAEliminar = nil } }),
                titleVisibility: .visible
            ) {
                Button("Eliminar con todo su historial", role: .destructive) {
                    if let mascota = mascotaAEliminar {
                        eliminar(mascota)
                    }
                    mascotaAEliminar = nil
                }
                Button("Cancelar", role: .cancel) {
                    mascotaAEliminar = nil
                }
            } message: {
                Text("Se borrarán sus vacunas, alergias y demás registros. Esta acción no se puede deshacer.")
            }
        }
    }

    private func eliminar(_ mascota: Mascota) {
        viewContext.delete(mascota)
        try? viewContext.save()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
