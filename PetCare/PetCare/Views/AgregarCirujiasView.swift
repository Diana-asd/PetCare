//
//  AgregarCirujiasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarCirugiaView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var gravedad = "Menor"
    @State private var fecha = Date()
    @State private var veterinario = ""
    @State private var notas = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Cirugía") {
                    TextField("Nombre (ej. Esterilización)", text: $nombre)
                    Picker("Tipo", selection: $gravedad) {
                        Text("Menor").tag("Menor")
                        Text("Mayor").tag("Mayor")
                    }
                    .pickerStyle(.segmented)
                    DatePicker("Fecha", selection: $fecha,
                               in: ...Date(), displayedComponents: .date)
                }
                Section("Detalles") {
                    TextField("Veterinario o clínica (opcional)", text: $veterinario)
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nueva cirugía")
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
        let cirugia = Cirugia(context: viewContext)
        cirugia.id = UUID()
        cirugia.nombre = nombre.trimmingCharacters(in: .whitespaces)
        cirugia.gravedad = gravedad
        cirugia.fecha = fecha
        cirugia.veterinario = veterinario.isEmpty ? nil : veterinario
        cirugia.notas = notas.isEmpty ? nil : notas
        cirugia.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar cirugía: \(error)")
        }
    }
}
