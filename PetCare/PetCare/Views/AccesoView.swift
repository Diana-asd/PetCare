//
//  AccesoView.swift
//  PetCare
//
//  Created by Christian on 27/11/26.
//

import Foundation
import SwiftUI

struct AccesoView: View {
    @EnvironmentObject private var auth: AuthViewModel

    private enum Modo: String, CaseIterable, Identifiable {
        case ingresar = "Iniciar sesión"
        case registrar = "Crear cuenta"
        var id: String { rawValue }
    }

    @State private var modo: Modo = .ingresar
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var confirmacion = ""

    private var correoLimpio: String {
        correo.trimmingCharacters(in: .whitespaces)
    }

    private var formularioValido: Bool {
        guard correoLimpio.contains("@"), correoLimpio.contains("."),
              contrasena.count >= 6 else { return false }
        return modo == .ingresar || contrasena == confirmacion
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                encabezado

                Picker("Modo", selection: $modo) {
                    ForEach(Modo.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 12) {
                    TextField("Correo electrónico", text: $correo)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .campoEstilo()
                    SecureField("Contraseña (mínimo 6 caracteres)", text: $contrasena)
                        .campoEstilo()
                    if modo == .registrar {
                        SecureField("Confirmar contraseña", text: $confirmacion)
                            .campoEstilo()
                        if !confirmacion.isEmpty && confirmacion != contrasena {
                            Text("Las contraseñas no coinciden.")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                mensajes
                botonPrincipal

                if modo == .ingresar {
                    Button("¿Olvidaste tu contraseña?") {
                        Task { await auth.recuperarContrasena(correo: correoLimpio) }
                    }
                    .font(.footnote)
                }
            }
            .padding(24)
        }
        .background { FondoPatitas() }
        .onChange(of: modo) { _, _ in
            auth.mensajeError = nil
            auth.mensajeInfo = nil
        }
    }

    private var encabezado: some View {
        VStack(spacing: 10) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white)
                .frame(width: 92, height: 92)
                .background(Color.accentColor, in: Circle())
            Text("PetCare")
                .font(.largeTitle.bold())
            Text(modo == .ingresar
                 ? "Inicia sesión para ver el historial de tus mascotas"
                 : "Crea tu cuenta para guardar el historial de tus mascotas")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 30)
    }

    @ViewBuilder
    private var mensajes: some View {
        if let error = auth.mensajeError {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
        if let info = auth.mensajeInfo {
            Text(info)
                .font(.footnote)
                .foregroundStyle(.green)
                .multilineTextAlignment(.center)
        }
    }

    private var botonPrincipal: some View {
        Button {
            Task {
                if modo == .ingresar {
                    await auth.iniciarSesion(correo: correoLimpio, contrasena: contrasena)
                } else {
                    await auth.registrar(correo: correoLimpio, contrasena: contrasena)
                }
            }
        } label: {
            Group {
                if auth.cargando {
                    ProgressView().tint(.white)
                } else {
                    Text(modo == .ingresar ? "Entrar" : "Crear cuenta")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(formularioValido ? Color.accentColor : Color.gray.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!formularioValido || auth.cargando)
    }
}

private extension View {
    func campoEstilo() -> some View {
        self
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 14))
    }
}
