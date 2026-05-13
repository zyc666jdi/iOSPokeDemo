import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("⚡")
                    .font(.system(size: 80))

                Text("pokeSearch")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Discover Pokémon species")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }
}
