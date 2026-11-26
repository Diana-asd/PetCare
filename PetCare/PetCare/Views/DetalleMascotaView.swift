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
        let categoria: Tema.Categoria
        let cantidad: Int
    }

    private var secciones: [Seccion] {
        [
            Seccion(titulo: "Vacunas", icono: "syringe", categoria: .vacunas,
                    cantidad: mascota.vacunas?.count ?? 0),
            Seccion(titulo: "Desparasitaciones", icono: "ladybug", categoria: .desparasitaciones,
                    cantidad: mascota.desparasitaciones?.count ?? 0),
            Seccion(titulo: "Alergias", icono: "allergens", categoria: .alergias,
                    cantidad: mascota.alergias?.count ?? 0),
            Seccion(titulo: "Enfermedades", icono: "cross.case", categoria: .enfermedades,
                    cantidad: mascota.enfermedades?.count ?? 0),
            Seccion(titulo: "Cirugías", icono: "scissors", categoria: .cirugias,
                    cantidad: mascota.cirugias?.count ?? 0),
            Seccion(titulo: "Síntomas", icono: "waveform.path.ecg", categoria: .sintomas,
                    cantidad: mascota.sintomas?.count ?? 0)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                relleno
                encabezado
                VStack(spacing: 12) {
                    tarjetaFicha
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
                        .tarjetaEstilo()
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

    // MARK: - Piezas de la pantalla
    private var relleno: some View {
            Color.clear
                .frame(height: 0)
                .overlay(alignment: .bottom) {
                    Color.accentColor.opacity(0.28)
                        .frame(height: 1200)
                        .allowsHitTesting(false)
                }
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
            Text(mascota.subtituloResumen)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [Color.accentColor.opacity(0.28),
                                    Color.accentColor.opacity(0.08)],
                           startPoint: .top, endPoint: .bottom)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32,
                                                  bottomTrailingRadius: 32))
        )
    }

    private var tarjetaFicha: some View {
        NavigationLink {
            ResumenVeterinarioView(mascota: mascota)
        } label: {
            HStack(spacing: 14) {
                InsigniaIcono(sistema: "doc.text.magnifyingglass", color: .accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ficha para el veterinario").font(.headline)
                    Text("Resumen y compartir en PDF")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color.accentColor.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: Tema.radioTarjeta))
            .overlay(
                RoundedRectangle(cornerRadius: Tema.radioTarjeta)
                    .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func tarjeta(_ seccion: Seccion) -> some View {
        HStack(spacing: 14) {
            InsigniaIcono(sistema: seccion.icono, color: seccion.categoria.color)
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
        .tarjetaEstilo()
    }

    // MARK: - Navegación y acciones

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
