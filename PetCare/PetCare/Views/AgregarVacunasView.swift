//
//  AgregarVacunasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarVacunaView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var fecha = Date()
    @State private var programarRefuerzo = false
    @State private var proximaFecha = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var veterinario = ""
    @State private var notas = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vacuna") {
                    TextField("Nombre (ej. Antirrábica)", text: $nombre)
                    DatePicker("Fecha de aplicación", selection: $fecha,
                               in: ...Date(), displayedComponents: .date)
                }
                Section("Refuerzo") {
                    Toggle("Programar próximo refuerzo", isOn: $programarRefuerzo)
                    if programarRefuerzo {
                        DatePicker("Próxima fecha", selection: $proximaFecha,
                                   in: fecha..., displayedComponents: .date)
                    }
                }
                Section("Detalles") {
                    TextField("Veterinario o clínica (opcional)", text: $veterinario)
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nueva vacuna")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func guardar() {
        let vacuna = Vacuna(context: viewContext)
        vacuna.id = UUID()
        vacuna.nombre = nombre.trimmingCharacters(in: .whitespaces)
        vacuna.fecha = fecha
        vacuna.proximaFecha = programarRefuerzo ? proximaFecha : nil
        vacuna.veterinario = veterinario.isEmpty ? nil : veterinario
        vacuna.notas = notas.isEmpty ? nil : notas
        vacuna.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar vacuna: \(error)")
        }
    }
}
