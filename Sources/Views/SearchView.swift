import SwiftUI

struct SearchView: View {
    @Binding var path: [Pokemon]
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            contentArea
        }
        .navigationTitle("pokeSearch")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(pokemon: pokemon)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search Pokémon species...", text: $viewModel.searchText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: viewModel.searchText) { newValue in
                    viewModel.onSearchTextChanged(newValue)
                }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.species.isEmpty {
            loadingView
        } else if let error = viewModel.errorMessage, viewModel.species.isEmpty {
            errorView(error)
        } else if viewModel.species.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
            emptyView
        } else if viewModel.species.isEmpty {
            placeholderView
        } else {
            resultsList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No results found")
                .font(.headline)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.and.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Search Pokémon Species")
                .font(.headline)
            Text("Type a name to start")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsList: some View {
        List {
            ForEach(viewModel.species) { species in
                SpeciesRowView(species: species, onSelect: { pokemon in
                    path.append(pokemon)
                })
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else if viewModel.hasMore {
                Color.clear
                    .frame(height: 1)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        viewModel.loadNextPage()
                    }
            }
        }
        .listStyle(.plain)
    }
}
