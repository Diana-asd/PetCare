//
//  EnfermedadesView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct EnfermedadesView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var enfermedades: FetchedResults<Enfermedad>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _enfermedades = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Enfermedad.fechaInicio, ascending: false)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(enfermedades) { enfermedad in
                fila(enfermedad)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if enfermedades.isEmpty {
                ContentUnavailableView("Sin enfermedades",
                                       systemImage: "cross.case",
                                       description: Text("Toca + para registrar una"))
            }
        }
        .navigationTitle("Enfermedades").fondoLista()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarEnfermedadView(mascota: mascota)
        }
    }

    private func fila(_ enfermedad: Enfermedad) -> some View {
        let estado = enfermedad.estado ?? "Activa"
        let color: Color = estado == "Activa" ? .orange : .green
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(enfermedad.nombre ?? "Sin nombre")
                    .font(.headline)
                Spacer()
                Text(estado)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15), in: Capsule())
                    .foregroundStyle(color)
            }
            if let inicio = enfermedad.fechaInicio {
                Text("Desde: \(inicio.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let tratamiento = enfermedad.tratamiento, !tratamiento.isEmpty {
                Text("Tratamiento: \(tratamiento)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notas = enfermedad.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { enfermedades[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
