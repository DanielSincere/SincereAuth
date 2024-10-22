import Foundation

enum AuthConstant {
  static let refreshTokenLifetime: TimeInterval = .oneDay * 3
  static let accessTokenLifetime: TimeInterval = .oneHour * 0.5
}

extension TimeInterval {
  static let oneDay: Self = 24 * Self.oneHour
  static let oneHour: Self = 60 * 60
}
