import Foundation

struct PokemonSpecies: Identifiable, Sendable, Hashable {
    let id: Int
    let name: String
    let captureRate: Int
    let color: String
    let pokemons: [Pokemon]
}

struct Pokemon: Identifiable, Sendable, Hashable {
    let id: Int
    let name: String
    let abilities: [String]
}
