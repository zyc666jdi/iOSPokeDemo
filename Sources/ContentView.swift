import SwiftUI

struct ContentView: View {
    @State private var path: [Pokemon] = []

    var body: some View {
        NavigationStack(path: $path) {
            SearchView(path: $path)
        }
    }
}
