//
//  ResumenVeterinarioView.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//

import Foundation
import SwiftUI

struct ResumenVeterinarioView: View {
    @ObservedObject var mascota: Mascota
    @State private var pdfURL: URL?
    @State private var archivoURL: URL?

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    FotoMascotaView(data: mascota.foto, tamano: 64)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mascota.nombre ?? "Sin nombre")
                            .font(.title2.bold())
                        Text(mascota.subtituloResumen)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Alergias") {
                if mascota.alergiasOrdenadas.isEmpty { vacio("Sin alergias registradas") }
                ForEach(mascota.alergiasOrdenadas) { alergia in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alergia.alergeno ?? "—").font(.headline)
                        if let r = alergia.reaccion, !r.isEmpty {
                            Text("Reacción: \(r)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Enfermedades") {
                if mascota.enfermedadesOrdenadas.isEmpty { vacio("Sin enfermedades registradas") }
                ForEach(mascota.enfermedadesOrdenadas) { enfermedad in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(enfermedad.nombre ?? "—").font(.headline)
                            Spacer()
                            Text(enfermedad.estado ?? "Activa")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle((enfermedad.estado ?? "Activa") == "Activa" ? .orange : .green)
                        }
                        if let t = enfermedad.tratamiento, !t.isEmpty {
                            Text("Tratamiento: \(t)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Cirugías") {
                if mascota.cirugiasOrdenadas.isEmpty { vacio("Sin cirugías registradas") }
                ForEach(mascota.cirugiasOrdenadas) { cirugia in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(cirugia.nombre ?? "—") (\(cirugia.gravedad ?? "Menor"))")
                            .font(.headline)
                        if let f = cirugia.fecha {
                            Text(f.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Vacunas (última dosis de cada una)") {
                if mascota.vacunasVigentes.isEmpty { vacio("Sin vacunas registradas") }
                ForEach(mascota.vacunasVigentes) { vacuna in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(vacuna.nombre ?? "—").font(.headline)
                            Spacer()
                            if let estado = EstadoRefuerzo.desde(vacuna.proximaFecha) {
                                Text(estado.texto)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(estado.color.opacity(0.15), in: Capsule())
                                    .foregroundStyle(estado.color)
                            }
                        }
                        if let f = vacuna.fecha {
                            Text("Aplicada: \(f.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Desparasitaciones recientes") {
                if mascota.desparasitacionesOrdenadas.isEmpty { vacio("Sin desparasitaciones registradas") }
                ForEach(Array(mascota.desparasitacionesOrdenadas.prefix(3))) { registro in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(registro.producto ?? "—").font(.headline)
                        if let f = registro.fecha {
                            Text(f.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Síntomas recientes") {
                if mascota.sintomasOrdenados.isEmpty { vacio("Sin síntomas registrados") }
                ForEach(Array(mascota.sintomasOrdenados.prefix(5))) { sintoma in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sintoma.descripcion ?? "—").font(.headline)
                        if let f = sintoma.fecha {
                            Text(f.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Ficha veterinaria").fondoLista()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if let pdfURL {
                                ShareLink(item: pdfURL,
                                          subject: Text("Ficha de \(mascota.nombre ?? "mascota")"),
                                          message: Text("Ficha veterinaria generada con PetCare")) {
                                    Label("Compartir PDF", systemImage: "doc.richtext")
                                }
                            }
                            if let archivoURL {
                                ShareLink(item: archivoURL) {
                                    Label("Enviar a otro PetCare", systemImage: "iphone.and.arrow.forward")
                                }
                            }
                        } label: {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                .onAppear {
                    pdfURL = PDFFichaGenerator.generarArchivo(para: mascota)
                    archivoURL = MascotaExportable(mascota).escribirArchivo()
                }
    }

    private func vacio(_ texto: String) -> some View {
        Text(texto).foregroundStyle(.secondary)
    }
}
