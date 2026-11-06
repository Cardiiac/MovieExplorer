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

protocol MovieServiceProtocol {
    func obtenerPeliculas() async throws -> [Movie]
}

final class MovieService: MovieServiceProtocol {
    private let endpointURL = "https://api.tvmaze.com/shows"

    func obtenerPeliculas() async throws -> [Movie] {
        guard let url = URL(string: endpointURL) else {
            throw NetworkError.urlInvalida
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.respuestaServidorInvalida(codigo: 0)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.respuestaServidorInvalida(codigo: httpResponse.statusCode)
            }

            let peliculas = try JSONDecoder().decode([Movie].self, from: data)
            return peliculas
        } catch let error as DecodingError {
            print("Decoding Error: \(error)")
            throw NetworkError.errorDecodificacion
        } catch let error as URLError {
            print("URL Error: \(error)")
            throw NetworkError.sinConexion
        } catch {
            throw error
        }
    }
}
