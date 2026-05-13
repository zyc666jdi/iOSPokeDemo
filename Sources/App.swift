import SwiftUI

@main
struct iOSPokeDemo: App {
    @State private var showSplash: Bool = {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        return !hasLaunched
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                guard showSplash else { return }
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
        }
    }
}
