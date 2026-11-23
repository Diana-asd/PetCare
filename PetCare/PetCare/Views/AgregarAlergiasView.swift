//
//  AgregarAlergiasView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarAlergiaView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var alergeno = ""
    @State private var reaccion = ""
    @State private var conoceFecha = false
    @State private var fechaDeteccion = Date()
    @State private var notas = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Alergia") {
                    TextField("A qué es alérgica (ej. pollo, penicilina)", text: $alergeno)
                    TextField("Reacción (ej. picazón, vómitos)", text: $reaccion)
                }
                Section("Detección") {
                    Toggle("Conozco la fecha", isOn: $conoceFecha)
                    if conoceFecha {
                        DatePicker("Fecha", selection: $fechaDeteccion,
                                   in: ...Date(), displayedComponents: .date)
                    }
                }
                Section("Notas") {
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nueva alergia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(alergeno.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func guardar() {
        let alergia = Alergia(context: viewContext)
        alergia.id = UUID()
        alergia.alergeno = alergeno.trimmingCharacters(in: .whitespaces)
        alergia.reaccion = reaccion.isEmpty ? nil : reaccion
        alergia.fechaDeteccion = conoceFecha ? fechaDeteccion : nil
        alergia.notas = notas.isEmpty ? nil : notas
        alergia.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar alergia: \(error)")
        }
    }
}
