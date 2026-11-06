//
//  MovieExplorerView.swift
//  MovieExplorer
//
//  Created for Evaluación Continua PA3 - Pregunta 5
//

import SwiftUI

struct MovieExplorerView: View {
    @State private var viewModel = MovieExplorerViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selector de géneros horizontal (solo visible cuando hay datos)
                if case .exitoso = viewModel.estado, !viewModel.peliculas.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.generosDisponibles, id: \.self) { genero in
                                let seleccionado = viewModel.generoSeleccionado == genero
                                Text(genero)
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(seleccionado ? Color.blue : Color.gray.opacity(0.15))
                                    .foregroundStyle(seleccionado ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        viewModel.generoSeleccionado = genero
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }

                // Manejo de los 4 estados de la vista
                Group {
                    switch viewModel.estado {
                    case .cargando:
                        // 1. ESTADO DE CARGA OBLIGATORIO
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.3)
                            Text("Cargando catálogo de películas...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .error(let mensaje):
                        // 2. ESTADO DE ERROR OBLIGATORIO
                        ContentUnavailableView {
                            Label("Error de Conexión", systemImage: "wifi.exclamationmark")
                        } description: {
                            Text(mensaje)
                        } actions: {
                            Button("Reintentar") {
                                Task {
                                    await viewModel.reintentar()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .exitoso:
                        if viewModel.esEstadoVacio {
                            // 3. ESTADO VACÍO OBLIGATORIO (Búsqueda sin resultados)
                            ContentUnavailableView {
                                Label("Sin resultados", systemImage: "film.slash")
                            } description: {
                                Text("No se encontraron títulos que coincidan con \"\(viewModel.textoBusqueda)\".")
                            } actions: {
                                Button("Limpiar búsqueda") {
                                    viewModel.textoBusqueda = ""
                                    viewModel.generoSeleccionado = "Todos"
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // 4. CONSUMO EXITOSO CON LAZYVGRID ADAPTATIVO
                            MovieGridView(peliculas: viewModel.peliculasFiltradas)
                        }
                    }
                }
            }
            .navigationTitle("Movie Explorer")
            // REQUISITO: Búsqueda local integrada
            .searchable(
                text: $viewModel.textoBusqueda,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Buscar películas..."
            )
            .toolbar {
                // Menú para facilitar la toma de evidencias del examen
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            Task { await viewModel.cargarPeliculas(forzarError: false) }
                        } label: {
                            Label("Recargar Catálogo", systemImage: "arrow.clockwise")
                        }

                        Button(role: .destructive) {
                            Task { await viewModel.alternarSimulacionError() }
                        } label: {
                            Label("Simular Error de Red (Para Evidencia)", systemImage: "bolt.horizontal.slash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
            .task {
                if viewModel.peliculas.isEmpty {
                    await viewModel.cargarPeliculas()
                }
            }
            .refreshable {
                await viewModel.cargarPeliculas()
            }
        }
    }
}
