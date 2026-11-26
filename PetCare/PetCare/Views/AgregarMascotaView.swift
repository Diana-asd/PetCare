//
//  AgregarMascotaView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import CoreData
import PhotosUI

struct AgregarMascotaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var especie = "Perro"
    @State private var raza = ""
    @State private var sexo = "Macho"
    @State private var conoceFecha = true
    @State private var fechaNac = Date()
    @State private var notas = ""
    @State private var fotoItem: PhotosPickerItem?
    @State private var fotoData: Data?

    private let especies = ["Perro", "Gato", "Vaca", "Cerdo", "Gallina", "Otro"]

    var body: some View {
            NavigationStack {
                Form {
                    Section {
                        HStack {
                            Spacer()
                            PhotosPicker(selection: $fotoItem, matching: .images) {
                                VStack(spacing: 8) {
                                    FotoMascotaView(data: fotoData, tamano: 100)
                                    Text(fotoData == nil ? "Agregar foto" : "Cambiar foto")
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }

                    Section("Datos básicos") {
                        TextField("Nombre", text: $nombre)
                        Picker("Especie", selection: $especie) {
                            ForEach(especies, id: \.self) { Text($0) }
                        }
                        TextField("Raza (opcional)", text: $raza)
                        Picker("Sexo", selection: $sexo) {
                            Text("Macho").tag("Macho")
                            Text("Hembra").tag("Hembra")
                        }
                    }
                    Section("Nacimiento") {
                        Toggle("Conozco la fecha de nacimiento", isOn: $conoceFecha)
                        if conoceFecha {
                            DatePicker("Fecha", selection: $fechaNac,
                                       in: ...Date(), displayedComponents: .date)
                        }
                    }
                    Section("Notas") {
                        TextField("Notas (opcional)", text: $notas, axis: .vertical)
                    }
                }
                .navigationTitle("Nueva mascota").fondoLista()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar", action: guardar)
                            .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .onChange(of: fotoItem) { _, nuevo in
                    guard let nuevo else { return }
                    Task {
                        if let data = try? await nuevo.loadTransferable(type: Data.self) {
                            fotoData = ImagenHelper.reducir(data)
                        }
                    }
                }
            }
        }

        private func guardar() {
            let mascota = Mascota(context: viewContext)
            mascota.id = UUID()
            mascota.nombre = nombre.trimmingCharacters(in: .whitespaces)
            mascota.especie = especie
            mascota.raza = raza.isEmpty ? nil : raza
            mascota.sexo = sexo
            mascota.fechaNac = conoceFecha ? fechaNac : nil
            mascota.notas = notas.isEmpty ? nil : notas
            mascota.foto = fotoData
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Error al guardar: \(error)")
            }
        }
    }
