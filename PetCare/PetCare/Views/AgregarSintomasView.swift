//
//  AgregarSintomasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarSintomaView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var descripcion = ""
    @State private var fecha = Date()
    @State private var severidad = "Sin indicar"
    @State private var notas = ""

    private let severidades = ["Sin indicar", "Leve", "Moderada", "Grave"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Síntoma") {
                    TextField("Qué observas (ej. vómitos, cojera)", text: $descripcion,
                              axis: .vertical)
                    DatePicker("Cuándo", selection: $fecha,
                               in: ...Date(),
                               displayedComponents: [.date, .hourAndMinute])
                    Picker("Severidad", selection: $severidad) {
                        ForEach(severidades, id: \.self) { Text($0) }
                    }
                }
                Section("Notas") {
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nuevo síntoma").fondoLista()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(descripcion.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func guardar() {
        let sintoma = Sintoma(context: viewContext)
        sintoma.id = UUID()
        sintoma.descripcion = descripcion.trimmingCharacters(in: .whitespaces)
        sintoma.fecha = fecha
        sintoma.severidad = severidad == "Sin indicar" ? nil : severidad
        sintoma.notas = notas.isEmpty ? nil : notas
        sintoma.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar síntoma: \(error)")
        }
    }
}
