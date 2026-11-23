//
//  DetalleMascotaView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI
import PhotosUI
public import CoreData

struct DetalleMascotaView: View {
    @ObservedObject var mascota: Mascota
    @Environment(\.managedObjectContext) private var viewContext
    @State private var fotoItem: PhotosPickerItem?

    private struct Seccion: Identifiable {
        let id = UUID()
        let titulo: String
        let icono: String
        let cantidad: Int
    }

    private var secciones: [Seccion] {
        [
            Seccion(titulo: "Vacunas", icono: "syringe", cantidad: mascota.vacunas?.count ?? 0),
            Seccion(titulo: "Desparasitaciones", icono: "ladybug", cantidad: mascota.desparasitaciones?.count ?? 0),
            Seccion(titulo: "Alergias", icono: "allergens", cantidad: mascota.alergias?.count ?? 0),
            Seccion(titulo: "Enfermedades", icono: "cross.case", cantidad: mascota.enfermedades?.count ?? 0),
            Seccion(titulo: "Cirugías", icono: "scissors", cantidad: mascota.cirugias?.count ?? 0),
            Seccion(titulo: "Síntomas", icono: "waveform.path.ecg", cantidad: mascota.sintomas?.count ?? 0)
        ]
    }

    private var edadTexto: String {
        guard let nac = mascota.fechaNac else { return "Edad desconocida" }
        let c = Calendar.current.dateComponents([.year, .month], from: nac, to: Date())
        let anios = c.year ?? 0
        let meses = c.month ?? 0
        switch (anios, meses) {
        case (0, let m): return m == 1 ? "1 mes" : "\(m) meses"
        case (let a, 0): return a == 1 ? "1 año" : "\(a) años"
        default: return "\(anios) \(anios == 1 ? "año" : "años") \(meses) \(meses == 1 ? "mes" : "meses")"
        }
    }

    private var subtitulo: String {
        [mascota.especie, mascota.raza, mascota.sexo, edadTexto]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                encabezado
                VStack(spacing: 12) {
                    ForEach(secciones) { seccion in
                        NavigationLink {
                            destino(para: seccion)
                        } label: {
                            tarjeta(seccion)
                        }
                        .buttonStyle(.plain)
                    }
                    if let notas = mascota.notas, !notas.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notas").font(.headline)
                            Text(notas).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground),
                                    in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: fotoItem) { _, nuevo in
                   guard let nuevo else { return }
                   Task {
                       if let data = try? await nuevo.loadTransferable(type: Data.self),
                          let reducida = ImagenHelper.reducir(data) {
                           guardarFoto(reducida)
                       }
                   }
               }
    }

    @ViewBuilder
        private func destino(para seccion: Seccion) -> some View {
            switch seccion.titulo {
            case "Vacunas":
                VacunasView(mascota: mascota)
            case "Desparasitaciones":
                        DesparasitacionesView(mascota: mascota)
            case "Alergias":
                AlergiasView(mascota: mascota)
            case "Enfermedades":
                EnfermedadesView(mascota: mascota)
            case "Cirugías":
                CirugiasView(mascota: mascota)
            case "Síntomas":
                SintomasView(mascota: mascota)
            default:
                SeccionPlaceholderView(titulo: seccion.titulo)
            }
        }
    
    private func guardarFoto(_ data: Data) {
            mascota.foto = data
            try? viewContext.save()
        }
    
    private var encabezado: some View {
        VStack(spacing: 8) {
            PhotosPicker(selection: $fotoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    FotoMascotaView(data: mascota.foto, tamano: 110)
                    Image(systemName: "camera.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                }
            }
            Text(mascota.nombre ?? "Sin nombre")
                .font(.largeTitle.bold())
            Text(subtitulo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(
            Color.accentColor.opacity(0.15)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32,
                                                  bottomTrailingRadius: 32))
        )
    }

    private func tarjeta(_ seccion: Seccion) -> some View {
        HStack(spacing: 14) {
            Image(systemName: seccion.icono)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(seccion.titulo).font(.headline)
                Text(seccion.cantidad == 0 ? "Sin registros"
                     : seccion.cantidad == 1 ? "1 registro"
                     : "\(seccion.cantidad) registros")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16))
    }
}

struct SeccionPlaceholderView: View {
    let titulo: String

    var body: some View {
        ContentUnavailableView(titulo,
                               systemImage: "hammer",
                               description: Text("Próximamente"))
            .navigationTitle(titulo)
    }
}
