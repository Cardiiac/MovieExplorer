//
//  MovieExplorerViewModel.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import Foundation
import Observation

enum EstadoVista: Equatable {
    case cargando
    case exitoso
    case error(mensaje: String)
}

@Observable
final class MovieExplorerViewModel {
    // MARK: - Estado de la Vista
    var estado: EstadoVista = .cargando
    var peliculas: [Movie] = []

    // MARK: - Filtros y Búsqueda Local
    var textoBusqueda: String = ""
    var generoSeleccionado: String = "Todos"

    // Servicio de red inyectado
    private let servicio: MovieServiceProtocol

    init(servicio: MovieServiceProtocol = MovieService()) {
        self.servicio = servicio
    }

    // MARK: - Géneros únicos disponibles
    var generosDisponibles: [String] {
        var setGeneros = Set<String>()
        for pelicula in peliculas {
            for genero in pelicula.genres {
                setGeneros.insert(genero)
            }
        }
        return ["Todos"] + Array(setGeneros).sorted()
    }

    // MARK: - Colección filtrada (Búsqueda local y por género)
    var peliculasFiltradas: [Movie] {
        var resultado = peliculas

        // Filtro por género seleccionado
        if generoSeleccionado != "Todos" {
            resultado = resultado.filter { $0.genres.contains(generoSeleccionado) }
        }

        // Filtro de búsqueda local por texto (título o sinopsis)
        let query = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            resultado = resultado.filter {
                $0.name.lowercased().contains(query) ||
                $0.sinopsisLimpia.lowercased().contains(query) ||
                $0.generosTexto.lowercased().contains(query)
            }
        }

        return resultado
    }

    // Indica si nos encontramos en estado vacío (búsqueda sin resultados)
    var esEstadoVacio: Bool {
        estado == .exitoso && peliculasFiltradas.isEmpty
    }

    // MARK: - Operaciones Asíncronas

    @MainActor
    func cargarPeliculas(forzarError: Bool = false) async {
        estado = .cargando

        // Simula una pequeña pausa para que el estado de carga sea visible
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 segundos

        if forzarError {
            self.estado = .error(mensaje: "No se pudo conectar con el servidor remoto (Error 503). Revisa tu conexión a internet.")
            return
        }

        do {
            let resultado = try await servicio.obtenerPeliculas()
            self.peliculas = resultado
            self.estado = .exitoso
        } catch {
            self.estado = .error(mensaje: error.localizedDescription)
        }
    }

    @MainActor
    func reintentar() async {
        await cargarPeliculas(forzarError: false)
    }

    @MainActor
    func alternarSimulacionError() async {
        await cargarPeliculas(forzarError: true)
    }
}
