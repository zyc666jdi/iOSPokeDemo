import SwiftUI

struct SpeciesRowView: View {
    let species: PokemonSpecies
    let onSelect: (Pokemon) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack(alignment: .top) {
                Text(species.name.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                captureRateBadge
            }

            Divider()

            // Pokémon chips
            if species.pokemons.isEmpty {
                Text("No Pokémon data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(species.pokemons) { pokemon in
                        Button {
                            onSelect(pokemon)
                        } label: {
                            Text(pokemon.name.capitalized.replacingOccurrences(of: "-", with: " "))
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Capsule())
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.pokémonColor(species.color))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.pokémonColor(species.color), lineWidth: 1)
        )
    }

    private var captureRateBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "scope")
                .font(.caption2)
            Text("\(species.captureRate)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.12))
        .clipShape(Capsule())
    }
}
