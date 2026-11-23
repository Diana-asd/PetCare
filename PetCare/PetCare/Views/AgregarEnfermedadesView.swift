//
//  AgregarEnfermedadesView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarEnfermedadView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var fechaInicio = Date()
    @State private var estado = "Activa"
    @State private var tratamiento = ""
    @State private var notas = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Enfermedad") {
                    TextField("Nombre o diagnóstico", text: $nombre)
                    DatePicker("Fecha de inicio", selection: $fechaInicio,
                               in: ...Date(), displayedComponents: .date)
                    Picker("Estado", selection: $estado) {
                        Text("Activa").tag("Activa")
                        Text("Resuelta").tag("Resuelta")
                    }
                    .pickerStyle(.segmented)
                }
                Section("Tratamiento") {
                    TextField("Tratamiento (opcional)", text: $tratamiento, axis: .vertical)
                }
                Section("Notas") {
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nueva enfermedad")
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
        let enfermedad = Enfermedad(context: viewContext)
        enfermedad.id = UUID()
        enfermedad.nombre = nombre.trimmingCharacters(in: .whitespaces)
        enfermedad.fechaInicio = fechaInicio
        enfermedad.estado = estado
        enfermedad.tratamiento = tratamiento.isEmpty ? nil : tratamiento
        enfermedad.notas = notas.isEmpty ? nil : notas
        enfermedad.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar enfermedad: \(error)")
        }
    }
}
