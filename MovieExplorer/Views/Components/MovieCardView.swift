//
//  MovieCardView.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import SwiftUI

struct MovieCardView: View {
    let pelicula: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster con AsyncImage
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: pelicula.posterURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.15)
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.2)
                            VStack(spacing: 4) {
                                Image(systemName: "film")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("Sin imagen")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Distintivo de Calificación
                if pelicula.calificacionFormateada != "N/D" {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(pelicula.calificacionFormateada)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(8)
                }
            }

            // Datos de la película
            VStack(alignment: .leading, spacing: 3) {
                Text(pelicula.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text(pelicula.anioEstreno)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(pelicula.generosTexto)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}
