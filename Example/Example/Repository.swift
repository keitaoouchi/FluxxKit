import Foundation
import Himotoki
import RxSwift

struct Repository: Decodable {
  let name: String

  static func decode(_ e: Extractor) throws -> Repository {
    return try Repository(
      name: e <| "full_name"
    )
  }
}

// MARK: - API
extension Repository {

  enum RepositoryError: Error {
    case decodeError
    case queryError
  }

  static func search(text: String) -> Observable<[Repository]> {
    return Observable.create { observer in

      if let url = URL(string: "https://api.github.com/search/repositories?q=\(text)&sort=stars&order=desc") {

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
          if let error = error {
            observer.onError(error)
            return
          }

          if let data = data,
            let json = try? JSONSerialization.jsonObject(
              with: data,
              options: JSONSerialization.ReadingOptions.allowFragments
            ),
            let repositories: [Repository] = try? decodeArray(json, rootKeyPath: "items") {

            observer.onNext(repositories)
            observer.onCompleted()
          } else {
            observer.onError(RepositoryError.decodeError)
          }
        }
        task.resume()

        return Disposables.create {
          if task.state == .running {
            task.cancel()
          }
        }

      } else {
        observer.onError(RepositoryError.queryError)
        return Disposables.create {}
      }

    }
  }
}
