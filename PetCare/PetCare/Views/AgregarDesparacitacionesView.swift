//
//  AgregarDesparacitacionesView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData

struct AgregarDesparasitacionView: View {
    let mascota: Mascota

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var producto = ""
    @State private var tipo = "Interna"
    @State private var fecha = Date()
    @State private var programarRefuerzo = true
    @State private var proximaFecha = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var notas = ""

    private let tipos = ["Interna", "Externa", "Ambas"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Desparasitación") {
                    TextField("Producto (ej. Drontal)", text: $producto)
                    Picker("Tipo", selection: $tipo) {
                        ForEach(tipos, id: \.self) { Text($0) }
                    }
                    DatePicker("Fecha de aplicación", selection: $fecha,
                               in: ...Date(), displayedComponents: .date)
                }
                Section("Próxima dosis") {
                    Toggle("Programar próxima dosis", isOn: $programarRefuerzo)
                    if programarRefuerzo {
                        DatePicker("Próxima fecha", selection: $proximaFecha,
                                   in: fecha..., displayedComponents: .date)
                    }
                }
                Section("Notas") {
                    TextField("Notas (opcional)", text: $notas, axis: .vertical)
                }
            }
            .navigationTitle("Nueva desparasitación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar)
                        .disabled(producto.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func guardar() {
        let registro = Desparasitacion(context: viewContext)
        registro.id = UUID()
        registro.producto = producto.trimmingCharacters(in: .whitespaces)
        registro.tipo = tipo
        registro.fecha = fecha
        registro.proximaFecha = programarRefuerzo ? proximaFecha : nil
        registro.notas = notas.isEmpty ? nil : notas
        registro.mascota = mascota
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error al guardar desparasitación: \(error)")
        }
    }
}
