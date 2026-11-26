//
//  AlergiasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AlergiasView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var alergias: FetchedResults<Alergia>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _alergias = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Alergia.alergeno, ascending: true)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(alergias) { alergia in
                fila(alergia)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if alergias.isEmpty {
                ContentUnavailableView("Sin alergias",
                                       systemImage: "allergens",
                                       description: Text("Toca + para registrar una"))
            }
        }
        .navigationTitle("Alergias").fondoLista()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarAlergiaView(mascota: mascota)
        }
    }

    private func fila(_ alergia: Alergia) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(alergia.alergeno ?? "Sin nombre")
                .font(.headline)
            if let reaccion = alergia.reaccion, !reaccion.isEmpty {
                Text("Reacción: \(reaccion)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let fecha = alergia.fechaDeteccion {
                Text("Detectada: \(fecha.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notas = alergia.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { alergias[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
