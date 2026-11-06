//
//  Movie.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import Foundation

// MARK: - Modelo de Película / Serie con decodificación Codable
struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let genres: [String]
    let rating: MovieRating?
    let image: MovieImage?
    let premiered: String?
    let summary: String?

    // Estructuras anidadas
    struct MovieRating: Codable, Hashable {
        let average: Double?
    }

    struct MovieImage: Codable, Hashable {
        let medium: String?
        let original: String?
    }

    // MARK: - Propiedades computadas para la interfaz

    var posterURL: URL? {
        if let original = image?.original, let url = URL(string: original) {
            return url
        }
        if let medium = image?.medium, let url = URL(string: medium) {
            return url
        }
        return nil
    }

    var calificacionFormateada: String {
        if let avg = rating?.average {
            return String(format: "%.1f", avg)
        }
        return "N/D"
    }

    var anioEstreno: String {
        guard let fecha = premiered, fecha.count >= 4 else { return "S/F" }
        return String(fecha.prefix(4))
    }

    var generosTexto: String {
        if genres.isEmpty { return "General" }
        return genres.joined(separator: ", ")
    }

    // Limpia las etiquetas HTML (<p>, <b>) que devuelve la API en el campo summary
    var sinopsisLimpia: String {
        guard let html = summary else { return "Sin sinopsis disponible." }
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
