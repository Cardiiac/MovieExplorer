//
//  MovieGridView.swift
//  MovieExplorer
//
//  RESTRICCIÓN OBLIGATORIA: Uso de ScrollView y LazyVGrid con GridItem(.adaptive(minimum: ...))
//

import SwiftUI

struct MovieGridView: View {
    let peliculas: [Movie]

    // RESTRICCIÓN OBLIGATORIA: Cuadrícula adaptativa que se ajusta a cualquier tamaño de pantalla
    private let columnas = [
        GridItem(.adaptive(minimum: 155), spacing: 16)
    ]

    @State private var peliculaSeleccionada: Movie? = nil

    var body: some View {
        // REQUISITO OBLIGATORIO: ScrollView envolviendo el LazyVGrid
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(columns: columnas, spacing: 18) {
                ForEach(peliculas) { pelicula in
                    MovieCardView(pelicula: pelicula)
                        .onTapGesture {
                            peliculaSeleccionada = pelicula
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .sheet(item: $peliculaSeleccionada) { pelicula in
            MovieDetailView(pelicula: pelicula)
        }
    }
}
