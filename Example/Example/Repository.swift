import Foundation

struct Repository: Codable, Identifiable, Sendable {
    let id: Int
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let language: String?
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case description
        case stargazersCount = "stargazers_count"
        case language
        case htmlUrl = "html_url"
    }
}

struct SearchResponse: Codable, Sendable {
    let items: [Repository]
}

enum GitHubAPI {
    static func search(query: String) async throws -> [Repository] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.github.com/search/repositories?q=\(encoded)&sort=stars")
        else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(SearchResponse.self, from: data).items
    }
}
