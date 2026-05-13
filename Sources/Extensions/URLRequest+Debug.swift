import Foundation

extension URLRequest {
    var curlString: String {
        guard let url = url else { return "curl command unavailable" }
        var components = ["curl -v"]
        components.append("-X \(httpMethod ?? "GET")")
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                components.append("-H '\(key): \(value)'")
            }
        }
        if let body = httpBody, let bodyString = String(data: body, encoding: .utf8) {
            components.append("-d '\(bodyString)'")
        }
        components.append("'\(url.absoluteString)'")
        return components.joined(separator: " \\\n  ")
    }
}
