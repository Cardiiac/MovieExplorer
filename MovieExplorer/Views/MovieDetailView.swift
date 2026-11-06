//
//  MovieDetailView.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import SwiftUI

struct MovieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let pelicula: Movie

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Cabecera con póster en alta resolución
                    AsyncImage(url: pelicula.posterURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 340)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.gray.opacity(0.18))
                                    .frame(height: 220)
                                Image(systemName: "film")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Título y Métricas
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pelicula.name)
                            .font(.title2.bold())

                        HStack(spacing: 12) {
                            // Calificación
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(pelicula.calificacionFormateada)
                                    .bold()
                            }
                            .font(.subheadline)

                            // Año
                            Text(pelicula.anioEstreno)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            // Géneros
                            Text(pelicula.generosTexto)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Divider()

                    // Sinopsis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sinopsis")
                            .font(.headline)

                        Text(pelicula.sinopsisLimpia)
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle(pelicula.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
