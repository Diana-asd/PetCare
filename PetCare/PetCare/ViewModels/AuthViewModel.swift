//
//  AuthViewModel.swift
//  PetCare
//
//  Created by Christian on 27/11/26.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var usuario: User?
    @Published var cargando = false
    @Published var mensajeError: String?
    @Published var mensajeInfo: String?

    private var listener: AuthStateDidChangeListenerHandle?

    init() {
        usuario = Auth.auth().currentUser
        listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.usuario = user
            }
        }
    }

    func iniciarSesion(correo: String, contrasena: String) async {
        await ejecutar {
            _ = try await Auth.auth().signIn(withEmail: correo, password: contrasena)
        }
    }

    func registrar(correo: String, contrasena: String) async {
        await ejecutar {
            _ = try await Auth.auth().createUser(withEmail: correo, password: contrasena)
        }
    }

    func recuperarContrasena(correo: String) async {
        guard !correo.isEmpty else {
            mensajeError = "Escribe tu correo arriba y vuelve a tocar este botón."
            mensajeInfo = nil
            return
        }
        await ejecutar {
            try await Auth.auth().sendPasswordReset(withEmail: correo)
            mensajeInfo = "Te enviamos un correo para restablecer tu contraseña. Revisa también la carpeta de spam."
        }
    }

    func cerrarSesion() {
        do {
            try Auth.auth().signOut()
        } catch {
            mensajeError = "No se pudo cerrar la sesión. Inténtalo de nuevo."
        }
    }

    private func ejecutar(_ accion: () async throws -> Void) async {
        cargando = true
        mensajeError = nil
        mensajeInfo = nil
        defer { cargando = false }
        do {
            try await accion()
        } catch {
            mensajeError = traducir(error)
        }
    }

    private func traducir(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain,
                      let codigo = AuthErrorCode(rawValue: nsError.code) else {
            return "Ocurrió un error. Inténtalo de nuevo."
        }
        switch codigo {
        case .invalidEmail:
            return "El correo no tiene un formato válido."
        case .wrongPassword, .invalidCredential, .userNotFound:
            return "Correo o contraseña incorrectos."
        case .emailAlreadyInUse:
            return "Ya existe una cuenta con ese correo."
        case .weakPassword:
            return "La contraseña es muy débil. Usa al menos 6 caracteres."
        case .networkError:
            return "Sin conexión a internet. Revisa tu red e inténtalo de nuevo."
        case .tooManyRequests:
            return "Demasiados intentos. Espera unos minutos e inténtalo otra vez."
        case .operationNotAllowed:
            return "El acceso con correo no está activado en Firebase."
        default:
            return "No se pudo completar la operación. Inténtalo de nuevo."
        }
    }
}
