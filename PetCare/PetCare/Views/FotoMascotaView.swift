//
//  FotoMascotaView.swift
//  PetCare
//
//  Created by Christian on 23/11/26.
//

import SwiftUI

struct FotoMascotaView: View {
    let data: Data?
    var tamano: CGFloat = 60

    var body: some View {
        Group {
            if let data, let imagen = UIImage(data: data) {
                Image(uiImage: imagen)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: tamano * 0.4))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: tamano, height: tamano)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 3))
    }
}
