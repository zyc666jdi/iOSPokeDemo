import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var species: [PokemonSpecies] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var hasMore: Bool = false

    private let pageSize = 20
    private var currentOffset = 0
    private var currentTask: Task<Void, Never>?

    func onSearchTextChanged(_ text: String) {
        currentTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            species = []
            currentOffset = 0
            hasMore = false
            isLoading = false
            return
        }
        currentTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            species = []
            currentOffset = 0
            await fetch(name: trimmed, offset: 0)
        }
    }

    func loadNextPage() {
        guard !isLoading, hasMore else { return }
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        currentTask = Task {
            await fetch(name: trimmed, offset: currentOffset)
        }
    }

    private func fetch(name: String, offset: Int) async {
        guard !Task.isCancelled else { return }
        isLoading = true
        errorMessage = nil
        do {
            let results = try await GraphQLClient.shared.searchSpecies(
                name: name, limit: pageSize, offset: offset
            )
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            species.append(contentsOf: results)
            currentOffset += results.count
            hasMore = results.count == pageSize
        } catch is CancellationError {
            // silently ignored
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
