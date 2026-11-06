//
//  MovieService.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import Foundation

enum NetworkError: LocalizedError {
    case urlInvalida
    case respuestaServidorInvalida(codigo: Int)
    case errorDecodificacion
    case sinConexion

    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "La URL del servicio no es válida."
        case .respuestaServidorInvalida(let codigo):
            return "Error en el servidor remoto (Código HTTP: \(codigo))."
        case .errorDecodificacion:
            return "No se pudo interpretar el formato JSON recibido."
        case .sinConexion:
            return "No se pudo establecer conexión con el servidor. Verifica tu conexión a internet."
        }
    }
}

// Estructura envoltorio para los resultados de búsqueda de la API
private struct TVMazeSearchItem: Codable {
    let show: Movie
}

protocol MovieServiceProtocol {
    func obtenerPeliculas() async throws -> [Movie]
}

final class MovieService: MovieServiceProtocol {
    // Lista de sagas favoritas solicitadas: Avengers, Spider-Man, X-Men, Iron Man, Wolverine
    private let categoriasSuperheroes = [
        "avengers",
        "spider-man",
        "x-men",
        "iron man",
        "wolverine"
    ]

    func obtenerPeliculas() async throws -> [Movie] {
        var peliculasUnicas: [Int: Movie] = [:]

        // Descarga concurrente mediante TaskGroup para mayor velocidad
        try await withThrowingTaskGroup(of: [Movie].self) { group in
            for termino in categoriasSuperheroes {
                group.addTask {
                    return try await self.buscarPeliculas(termino: termino)
                }
            }

            for try await resultados in group {
                for pelicula in resultados {
                    // Solo incluimos títulos que tengan póster y no estén repetidos
                    if pelicula.image != nil && peliculasUnicas[pelicula.id] == nil {
                        // Filtramos títulos no relacionados
                        let nombreMin = pelicula.name.lowercased()
                        if !nombreMin.contains("food") && !nombreMin.contains("funko") {
                            peliculasUnicas[pelicula.id] = pelicula
                        }
                    }
                }
            }
        }

        let listaFinal = Array(peliculasUnicas.values).sorted {
            ($0.rating?.average ?? 0) > ($1.rating?.average ?? 0)
        }

        if listaFinal.isEmpty {
            throw NetworkError.sinConexion
        }

        return listaFinal
    }

    private func buscarPeliculas(termino: String) async throws -> [Movie] {
        guard let terminoCodificado = termino.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.tvmaze.com/search/shows?q=\(terminoCodificado)") else {
            throw NetworkError.urlInvalida
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.respuestaServidorInvalida(codigo: 0)
        }

        let items = try JSONDecoder().decode([TVMazeSearchItem].self, from: data)
        return items.map { $0.show }
    }
}
