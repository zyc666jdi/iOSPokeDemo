import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Name header card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pokemon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(pokemon.name.capitalized.replacingOccurrences(of: "-", with: " "))
                            .font(.largeTitle.bold())
                    }
                    Spacer()
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.yellow)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Abilities section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Abilities", systemImage: "bolt.fill")
                        .font(.headline)
                        .padding(.horizontal)

                    if pokemon.abilities.isEmpty {
                        Text("No abilities found")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(pokemon.abilities, id: \.self) { ability in
                                HStack {
                                    Text(ability.capitalized.replacingOccurrences(of: "-", with: " "))
                                        .font(.body)
                                    Spacer()
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
