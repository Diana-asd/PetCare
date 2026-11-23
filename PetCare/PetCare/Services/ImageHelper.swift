//
//  ImageHelper.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import UIKit

enum ImagenHelper {
    static func reducir(_ data: Data, maxLado: CGFloat = 800) -> Data? {
        guard let imagen = UIImage(data: data) else { return nil }
        let escala = min(1, maxLado / max(imagen.size.width, imagen.size.height))
        let nuevoTamano = CGSize(width: imagen.size.width * escala,
                                 height: imagen.size.height * escala)
        let renderer = UIGraphicsImageRenderer(size: nuevoTamano)
        let reducida = renderer.image { _ in
            imagen.draw(in: CGRect(origin: .zero, size: nuevoTamano))
        }
        return reducida.jpegData(compressionQuality: 0.8)
    }
}
