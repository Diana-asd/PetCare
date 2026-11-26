//
//  DesparacitacionesView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct DesparasitacionesView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var registros: FetchedResults<Desparasitacion>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _registros = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Desparasitacion.fecha, ascending: false)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(registros) { registro in
                fila(registro)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if registros.isEmpty {
                ContentUnavailableView("Sin desparasitaciones",
                                       systemImage: "ladybug",
                                       description: Text("Toca + para registrar la primera"))
            }
        }
        .navigationTitle("Desparasitaciones").fondoLista()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarDesparasitacionView(mascota: mascota)
        }
    }

    private func fila(_ registro: Desparasitacion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(registro.producto ?? "Sin producto")
                    .font(.headline)
                Spacer()
                if let estado = EstadoRefuerzo.desde(registro.proximaFecha) {
                    Text(estado.texto)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(estado.color.opacity(0.15), in: Capsule())
                        .foregroundStyle(estado.color)
                }
            }
            if let fecha = registro.fecha {
                let tipo = (registro.tipo ?? "").isEmpty ? "" : " · \(registro.tipo ?? "")"
                Text("Aplicada: \(fecha.formatted(date: .abbreviated, time: .omitted))\(tipo)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let notas = registro.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { registros[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
