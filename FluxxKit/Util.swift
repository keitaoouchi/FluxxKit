import Foundation

struct Util {
  static func uuid() -> String {
    return NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
  }
}
