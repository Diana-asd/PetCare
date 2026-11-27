//
//  RespaldoView.swift
//  PetCare
//
//  Created by Christian on 27/11/26.
//

import Foundation
import SwiftUI
import CoreData

struct RespaldoView: View {
    let uid: String

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RespaldoViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Guarda una copia del historial de tus mascotas en tu cuenta. Si cambias de teléfono o reinstalas la app, inicia sesión y restáuralo.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        vm.respaldar(uid: uid, contexto: viewContext)
                    } label: {
                        Label("Respaldar ahora", systemImage: "icloud.and.arrow.up")
                    }
                    Button {
                        vm.restaurar(uid: uid, contexto: viewContext)
                    } label: {
                        Label("Restaurar desde la nube", systemImage: "icloud.and.arrow.down")
                    }
                } footer: {
                    Text("Restaurar solo agrega las mascotas que no están en este teléfono; no borra ni cambia las que ya tienes.")
                }
                .disabled(vm.trabajando)

                if vm.trabajando {
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Trabajando…")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let mensaje = vm.mensaje {
                    Section {
                        Text(mensaje)
                            .font(.subheadline)
                            .foregroundStyle(vm.esError ? .red : .green)
                    }
                }
            }
            .fondoLista()
            .navigationTitle("Respaldo en la nube")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}
