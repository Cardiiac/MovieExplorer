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
    var sagaSeleccionada: String = "Todos"

    // Sagas de superhéroes favoritas para filtrado rápido
    let sagasDisponibles = ["Todos", "Avengers", "Spider-Man", "X-Men", "Iron Man", "Wolverine"]

    // Servicio de red inyectado
    private let servicio: MovieServiceProtocol

    init(servicio: MovieServiceProtocol = MovieService()) {
        self.servicio = servicio
    }

    // MARK: - Colección filtrada (Búsqueda local y por saga)
    var peliculasFiltradas: [Movie] {
        var resultado = peliculas

        // Filtro por saga
        if sagaSeleccionada != "Todos" {
            let saga = sagaSeleccionada.lowercased()
            resultado = resultado.filter {
                $0.name.lowercased().contains(saga)
            }
        }

        // Filtro de búsqueda local por texto
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

        // Pequeña pausa para visualización del spinner de carga
        try? await Task.sleep(nanoseconds: 600_000_000)

        if forzarError {
            self.estado = .error(mensaje: "No se pudo conectar con el servidor de Marvel. Revisa tu conexión a internet.")
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
