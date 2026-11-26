//
//  VacunasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct VacunasView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var vacunas: FetchedResults<Vacuna>
    @State private var mostrarFormulario = false

    init(mascota: Mascota) {
        self.mascota = mascota
        _vacunas = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Vacuna.fecha, ascending: false)],
            predicate: NSPredicate(format: "mascota == %@", mascota),
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(vacunas) { vacuna in
                fila(vacuna)
            }
            .onDelete(perform: eliminar)
        }
        .overlay {
            if vacunas.isEmpty {
                ContentUnavailableView("Sin vacunas",
                                       systemImage: "syringe",
                                       description: Text("Toca + para registrar la primera"))
            }
        }
        .navigationTitle("Vacunas").fondoLista()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { mostrarFormulario = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            AgregarVacunaView(mascota: mascota)
        }
    }

    private func fila(_ vacuna: Vacuna) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(vacuna.nombre ?? "Sin nombre")
                    .font(.headline)
                Spacer()
                if let estado = estado(de: vacuna) {
                    Text(estado.texto)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(estado.color.opacity(0.15), in: Capsule())
                        .foregroundStyle(estado.color)
                }
            }
            if let fecha = vacuna.fecha {
                Text("Aplicada: \(fecha.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let vet = vacuna.veterinario, !vet.isEmpty {
                Text(vet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notas = vacuna.notas, !notas.isEmpty {
                Text(notas)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func estado(de vacuna: Vacuna) -> (texto: String, color: Color)? {
        guard let proxima = vacuna.proximaFecha else { return nil }
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: Date())
        let objetivo = calendario.startOfDay(for: proxima)
        let dias = calendario.dateComponents([.day], from: hoy, to: objetivo).day ?? 0
        if dias < 0 {
            return ("Vencida hace \(-dias) d", .red)
        } else if dias <= 30 {
            return (dias == 0 ? "Refuerzo hoy" : "Refuerzo en \(dias) d", .orange)
        } else {
            return ("Próxima: \(proxima.formatted(date: .abbreviated, time: .omitted))", .green)
        }
    }

    private func eliminar(_ offsets: IndexSet) {
        offsets.map { vacunas[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
