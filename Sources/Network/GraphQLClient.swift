import Foundation

// MARK: - Request

private struct GraphQLRequest<V: Encodable>: Encodable {
    let query: String
    let variables: V
}

private struct SearchVariables: Encodable {
    let name: String
    let limit: Int
    let offset: Int
}

// MARK: - Response

private struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

private struct GraphQLError: Decodable {
    let message: String
}

private struct SpeciesQueryData: Decodable {
    let pokemon_v2_pokemonspecies: [SpeciesNode]
}

private struct SpeciesNode: Decodable {
    let id: Int
    let name: String
    let capture_rate: Int
    let pokemon_v2_pokemoncolor: ColorNode
    let pokemon_v2_pokemons: [PokemonNode]
}

private struct ColorNode: Decodable {
    let id: Int
    let name: String
}

private struct PokemonNode: Decodable {
    let id: Int
    let name: String
    let pokemon_v2_pokemonabilities: [AbilitySlotNode]
}

private struct AbilitySlotNode: Decodable {
    let id: Int
    let pokemon_v2_ability: AbilityNode?
}

private struct AbilityNode: Decodable {
    let name: String
}

// MARK: - Errors

enum GraphQLClientError: Error, LocalizedError {
    case httpError(Int)
    case graphqlErrors([String])

    var errorDescription: String? {
        switch self {
        case .httpError(let code): return "HTTP error: \(code)"
        case .graphqlErrors(let msgs): return msgs.joined(separator: "; ")
        }
    }
}

// MARK: - Client

actor GraphQLClient {
    static let shared = GraphQLClient()

    private let endpoint = URL(string: "https://beta.pokeapi.co/graphql/v1beta")!
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let searchQuery = """
    query SearchSpecies($name: String!, $limit: Int!, $offset: Int!) {
      pokemon_v2_pokemonspecies(
        where: { name: { _ilike: $name } }
        limit: $limit
        offset: $offset
        order_by: { id: asc }
      ) {
        id
        name
        capture_rate
        pokemon_v2_pokemoncolor {
          id
          name
        }
        pokemon_v2_pokemons {
          id
          name
          pokemon_v2_pokemonabilities {
            id
            pokemon_v2_ability {
              name
            }
          }
        }
      }
    }
    """

    func searchSpecies(name: String, limit: Int, offset: Int) async throws -> [PokemonSpecies] {
        let body = GraphQLRequest(
            query: searchQuery,
            variables: SearchVariables(name: "%\(name)%", limit: limit, offset: offset)
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        printRequestInfo(request: request, parameters: [
            "name": "%\(name)%",
            "limit": limit,
            "offset": offset
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        printResponseInfo(response: response, data: data)

        if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
            throw GraphQLClientError.httpError(http.statusCode)
        }

        let graphqlResponse = try decoder.decode(GraphQLResponse<SpeciesQueryData>.self, from: data)

        if let errors = graphqlResponse.errors, !errors.isEmpty {
            throw GraphQLClientError.graphqlErrors(errors.map(\.message))
        }

        return (graphqlResponse.data?.pokemon_v2_pokemonspecies ?? []).map { node in
            PokemonSpecies(
                id: node.id,
                name: node.name,
                captureRate: node.capture_rate,
                color: node.pokemon_v2_pokemoncolor.name,
                pokemons: node.pokemon_v2_pokemons.map { pNode in
                    Pokemon(
                        id: pNode.id,
                        name: pNode.name,
                        abilities: pNode.pokemon_v2_pokemonabilities
                            .compactMap { $0.pokemon_v2_ability?.name }
                    )
                }
            )
        }
    }

    // MARK: - Debug Logging

    private func printRequestInfo(request: URLRequest, parameters: [String: Any]) {
        #if DEBUG
        let parameterPairs: [(String, String)] = parameters.map { (key, value) in (key, String(describing: value)) }
        DLog("🌐 Network Request:")
        DLog("Request URL: \(request.url?.absoluteString ?? "Unknown")")
        DLog("Method: \(request.httpMethod ?? "Unknown")")
        DLog("Content-Type: application/json")
        if let headers = request.allHTTPHeaderFields {
            DLog("Headers:")
            for (key, value) in headers {
                DLog("  \(key): \(value)")
            }
        }
        DLog("Parameters:")
        for (key, value) in parameterPairs {
            DLog("  \(key): \(value)")
        }
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            DLog("Body: \(bodyString)")
        }
        DLog("========== 🧪 cURL  ==========")
        DLog("\(request.curlString)")
        #endif
    }

    private func printResponseInfo(response: URLResponse, data: Data) {
        #if DEBUG
        DLog("========== 📥 Network Response ==========")
        if let httpResponse = response as? HTTPURLResponse {
            DLog("response url: \(httpResponse.url?.absoluteString ?? "")")
            DLog("Status Code: \(httpResponse.statusCode)")
            if !httpResponse.allHeaderFields.isEmpty {
                DLog("Response Headers:")
                for (key, value) in httpResponse.allHeaderFields {
                    DLog("  \(key): \(value)")
                }
            }
        }
        DLog("Response Body (async pretty print):")
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            DLog(prettyString)
        } else if let responseString = String(data: data, encoding: .utf8) {
            DLog(responseString)
        } else {
            DLog("Unable to parse response data")
        }
        DLog("======================================")
        #endif
    }
}
