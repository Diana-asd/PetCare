//
//  PDFFichaGenerator.swift
//  PetCare
//
//  Created by Christian on 25/11/26.
//

import Foundation
import UIKit

enum PDFFichaGenerator {

    static func generarArchivo(para mascota: Mascota) -> URL? {
        let datos = generarDatos(para: mascota)
        let nombre = (mascota.nombre ?? "Mascota")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Ficha-\(nombre).pdf")
        do {
            try datos.write(to: url, options: .atomic)
            return url
        } catch {
            print("Error al guardar el PDF: \(error)")
            return nil
        }
    }

    static func generarDatos(para mascota: Mascota) -> Data {
        let tamano = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: tamano)
        let cuerpo = UIFont.systemFont(ofSize: 11)

        return renderer.pdfData { contexto in
            let e = EscritorPDF(contexto: contexto)

            // Encabezado con foto
            let lado: CGFloat = 80
            let tieneFoto = mascota.foto.flatMap { UIImage(data: $0) } != nil
            let xTexto: CGFloat? = tieneFoto ? e.margen + lado + 16 : nil
            let yInicio = e.y
            e.foto(mascota.foto, lado: lado)
            e.texto("FICHA VETERINARIA",
                    fuente: .systemFont(ofSize: 10, weight: .semibold),
                    color: .gray, x: xTexto)
            e.texto(mascota.nombre ?? "Sin nombre",
                    fuente: .systemFont(ofSize: 26, weight: .bold),
                    x: xTexto, despues: 2)
            e.texto(mascota.subtituloResumen,
                    fuente: .systemFont(ofSize: 12),
                    color: .darkGray, x: xTexto)
            e.y = max(e.y, yInicio + (tieneFoto ? lado : 0)) + 6

            if let notas = mascota.notas, !notas.isEmpty {
                e.texto("Notas del propietario: \(notas)", fuente: cuerpo, color: .darkGray)
            }

            // Alergias
            e.seccion("Alergias")
            let alergias = mascota.alergiasOrdenadas
            if alergias.isEmpty {
                e.texto("Sin alergias registradas.", fuente: cuerpo, color: .gray)
            }
            for alergia in alergias {
                var linea = alergia.alergeno ?? "—"
                if let r = alergia.reaccion, !r.isEmpty { linea += " — reacción: \(r)" }
                if let f = alergia.fechaDeteccion { linea += " (detectada \(formato(f)))" }
                e.item(linea)
            }

            // Enfermedades
            e.seccion("Enfermedades")
            let enfermedades = mascota.enfermedadesOrdenadas
            if enfermedades.isEmpty {
                e.texto("Sin enfermedades registradas.", fuente: cuerpo, color: .gray)
            }
            for enfermedad in enfermedades {
                var linea = "\(enfermedad.nombre ?? "—") — \(enfermedad.estado ?? "Activa")"
                if let f = enfermedad.fechaInicio { linea += ", desde \(formato(f))" }
                if let t = enfermedad.tratamiento, !t.isEmpty { linea += ". Tratamiento: \(t)" }
                e.item(linea)
            }

            // Cirugías
            e.seccion("Cirugías")
            let cirugias = mascota.cirugiasOrdenadas
            if cirugias.isEmpty {
                e.texto("Sin cirugías registradas.", fuente: cuerpo, color: .gray)
            }
            for cirugia in cirugias {
                var linea = "\(cirugia.nombre ?? "—") (\(cirugia.gravedad ?? "Menor")) — \(formato(cirugia.fecha))"
                if let v = cirugia.veterinario, !v.isEmpty { linea += ". \(v)" }
                e.item(linea)
            }

            // Vacunas
            e.seccion("Vacunas")
            let vacunas = mascota.vacunasOrdenadas
            if vacunas.isEmpty {
                e.texto("Sin vacunas registradas.", fuente: cuerpo, color: .gray)
            }
            for vacuna in vacunas {
                var linea = "\(vacuna.nombre ?? "—") — aplicada \(formato(vacuna.fecha))"
                if let p = vacuna.proximaFecha { linea += ". Próximo refuerzo: \(formato(p))" }
                e.item(linea)
            }

            // Desparasitaciones
            e.seccion("Desparasitaciones")
            let desparasitaciones = mascota.desparasitacionesOrdenadas
            if desparasitaciones.isEmpty {
                e.texto("Sin desparasitaciones registradas.", fuente: cuerpo, color: .gray)
            }
            for registro in desparasitaciones {
                var linea = registro.producto ?? "—"
                if let t = registro.tipo, !t.isEmpty { linea += " (\(t))" }
                linea += " — \(formato(registro.fecha))"
                if let p = registro.proximaFecha { linea += ". Próxima: \(formato(p))" }
                e.item(linea)
            }

            // Síntomas recientes
            e.seccion("Síntomas recientes")
            let sintomas = Array(mascota.sintomasOrdenados.prefix(10))
            if sintomas.isEmpty {
                e.texto("Sin síntomas registrados.", fuente: cuerpo, color: .gray)
            }
            for sintoma in sintomas {
                var linea = sintoma.descripcion ?? "—"
                if let s = sintoma.severidad, !s.isEmpty { linea += " (\(s))" }
                linea += " — \(formato(sintoma.fecha))"
                e.item(linea)
            }

            // Aviso final
            e.y += 18
            e.texto("Información registrada por el propietario con la app PetCare el \(formato(Date())). No reemplaza un historial clínico veterinario.",
                    fuente: .systemFont(ofSize: 9), color: .gray)
        }
    }

    private static func formato(_ fecha: Date?) -> String {
        guard let fecha else { return "sin fecha" }
        return fecha.formatted(date: .abbreviated, time: .omitted)
    }
}

private final class EscritorPDF {
    let contexto: UIGraphicsPDFRendererContext
    let pagina = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
    let margen: CGFloat = 40
    var y: CGFloat = 40

    init(contexto: UIGraphicsPDFRendererContext) {
        self.contexto = contexto
        contexto.beginPage()
    }

    func asegurarEspacio(_ altura: CGFloat) {
        if y + altura > pagina.height - margen {
            contexto.beginPage()
            y = margen
        }
    }

    @discardableResult
    func texto(_ contenido: String, fuente: UIFont, color: UIColor = .black,
               x: CGFloat? = nil, despues: CGFloat = 4) -> CGFloat {
        let xPos = x ?? margen
        let ancho = pagina.width - margen - xPos
        let atributos: [NSAttributedString.Key: Any] = [
            .font: fuente,
            .foregroundColor: color
        ]
        let cadena = contenido as NSString
        let medida = cadena.boundingRect(
            with: CGSize(width: ancho, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: atributos,
            context: nil)
        let alto = ceil(medida.height)
        asegurarEspacio(alto)
        cadena.draw(in: CGRect(x: xPos, y: y, width: ancho, height: alto),
                    withAttributes: atributos)
        y += alto + despues
        return alto
    }

    func seccion(_ titulo: String) {
        asegurarEspacio(44)
        y += 12
        texto(titulo.uppercased(),
              fuente: .systemFont(ofSize: 12, weight: .bold),
              color: .systemBlue, despues: 3)
        let cg = contexto.cgContext
        cg.setStrokeColor(UIColor.systemBlue.cgColor)
        cg.setLineWidth(0.8)
        cg.move(to: CGPoint(x: margen, y: y))
        cg.addLine(to: CGPoint(x: pagina.width - margen, y: y))
        cg.strokePath()
        y += 6
    }

    func item(_ contenido: String) {
        texto("•  " + contenido, fuente: .systemFont(ofSize: 11), despues: 3)
    }

    func foto(_ datos: Data?, lado: CGFloat) {
        guard let datos, let imagen = UIImage(data: datos) else { return }
        let marco = CGRect(x: margen, y: y, width: lado, height: lado)
        let cg = contexto.cgContext
        cg.saveGState()
        UIBezierPath(ovalIn: marco).addClip()
        let escala = max(lado / imagen.size.width, lado / imagen.size.height)
        let ancho = imagen.size.width * escala
        let alto = imagen.size.height * escala
        imagen.draw(in: CGRect(x: marco.midX - ancho / 2,
                               y: marco.midY - alto / 2,
                               width: ancho, height: alto))
        cg.restoreGState()
    }
}
