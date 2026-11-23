//
//  CirugiasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct CirugiasView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var cirugias: FetchedResults<Cirugia>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _cirugias = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Cirugia.fecha, ascending: false)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(cirugias) { cirugia in
                fila(cirugia)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if cirugias.isEmpty {
                ContentUnavailableView("Sin cirugías",
                                       systemImage: "scissors",
                                       description: Text("Toca + para registrar una"))
            }
        }
        .navigationTitle("Cirugías")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarCirugiaView(mascota: mascota)
        }
    }

    private func fila(_ cirugia: Cirugia) -> some View {
        let gravedad = cirugia.gravedad ?? "Menor"
        let color: Color = gravedad == "Mayor" ? .red : .blue
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(cirugia.nombre ?? "Sin nombre")
                    .font(.headline)
                Spacer()
                Text("Cirugía \(gravedad.lowercased())")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15), in: Capsule())
                    .foregroundStyle(color)
            }
            if let fecha = cirugia.fecha {
                Text(fecha.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let vet = cirugia.veterinario, !vet.isEmpty {
                Text(vet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notas = cirugia.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { cirugias[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
