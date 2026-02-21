import Foundation

struct Repository: Codable, Identifiable {
  let id = UUID()
  let fullName: String

  enum CodingKeys: String, CodingKey {
    case fullName = "full_name"
  }
}

extension Repository {
  struct SearchResponse: Codable {
    let items: [Repository]
  }

  enum RepositoryError: Error {
    case queryError
  }

  static func search(text: String) async throws -> [Repository] {
    var components = URLComponents(string: "https://api.github.com/search/repositories")
    components?.queryItems = [
      .init(name: "q", value: text),
      .init(name: "sort", value: "stars"),
      .init(name: "order", value: "desc")
    ]

    guard let url = components?.url else {
      throw RepositoryError.queryError
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
    return decoded.items
  }
}
