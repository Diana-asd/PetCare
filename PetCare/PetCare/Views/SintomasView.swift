//
//  SintomasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct SintomasView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var sintomas: FetchedResults<Sintoma>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _sintomas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Sintoma.fecha, ascending: false)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(sintomas) { sintoma in
                fila(sintoma)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if sintomas.isEmpty {
                ContentUnavailableView("Sin síntomas",
                                       systemImage: "waveform.path.ecg",
                                       description: Text("Toca + para anotar uno"))
            }
        }
        .navigationTitle("Síntomas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarSintomaView(mascota: mascota)
        }
    }

    private func colorSeveridad(_ severidad: String) -> Color {
        switch severidad {
        case "Grave": return .red
        case "Moderada": return .orange
        default: return .green
        }
    }

    private func fila(_ sintoma: Sintoma) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(sintoma.descripcion ?? "Sin descripción")
                    .font(.headline)
                Spacer()
                if let severidad = sintoma.severidad, !severidad.isEmpty {
                    let color = colorSeveridad(severidad)
                    Text(severidad)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.15), in: Capsule())
                        .foregroundStyle(color)
                }
            }
            if let fecha = sintoma.fecha {
                Text(fecha.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let notas = sintoma.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { sintomas[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
