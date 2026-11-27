//
//  ContentView.swift
//  PetCare
//
//  Created by Christian on 19/11/26.
//
import SwiftUI
import CoreData
import FirebaseAuth

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var auth: AuthViewModel

    private let uid: String

    @FetchRequest private var mascotas: FetchedResults<Mascota>

    @State private var mostrarFormulario = false
    @State private var mascotaAEliminar: Mascota?
    @State private var mostrarRespaldo = false

    init(uid: String) {
        self.uid = uid
        _mascotas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Mascota.nombre, ascending: true)],
            predicate: NSPredicate(format: "propietarioUID == %@", uid),
            animation: .default)
    }

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        if let correo = auth.usuario?.email {
                            Text(correo)
                        }
                        Button {
                            mostrarRespaldo = true
                                } label: {
                                Label("Respaldo en la nube", systemImage: "icloud.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            auth.cerrarSesion()
                        } label: {
                            Label("Cerrar sesión",
                                  systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { mostrarFormulario = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $mostrarFormulario) {
                AgregarMascotaView()
                RespaldoView(uid: uid)
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
        .onAppear {
            adoptarHuerfanas()
        }
    }

    private func eliminar(_ mascota: Mascota) {
            let id = mascota.id
            viewContext.delete(mascota)
            try? viewContext.save()
            if let id {
                RespaldoService.eliminarEnNube(uid: uid, id: id)
            }
        }

    /// Las mascotas creadas antes del login no tienen dueño:
    private func adoptarHuerfanas() {
        let peticion: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        peticion.predicate = NSPredicate(format: "propietarioUID == nil")
        guard let huerfanas = try? viewContext.fetch(peticion),
              !huerfanas.isEmpty else { return }
        huerfanas.forEach { $0.propietarioUID = uid }
        try? viewContext.save()
    }
}
