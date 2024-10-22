import Vapor

enum EnvVars: String, CaseIterable {

  /// generate with `spx generate-jwt-key`
  case authPrivateKey = "AUTH_PRIVATE_KEY"

  /// Self issuer ID. What do you want your issuer's name to be?
  case selfIssuerId = "SELF_ISSUER_ID"

  /// from https://developer.apple.com/account/resources/authkeys/list
  case appleServicesKey = "APPLE_SERVICES_KEY"
  case appleServicesKeyId = "APPLE_SERVICES_KEY_ID"

  /// App Store Connect Team ID
  case appleTeamId = "APPLE_TEAM_ID"

  /// App Store Connect App Bundle ID
  case appleAppId = "APPLE_APP_ID"
  /// App Store Connect App Bundle IDs for secondary apps in your app group, delimited by spaces
  case additionalAppleAppIds = "ADDITIONAL_APPLE_APP_IDS"

  /// generate with `spx generate-db-key`
  case dbSymmetricKey = "DB_SYMMETRIC_KEY"

  /// from your hosting provider
  case postgresUrl = "DATABASE_URL"
  case redisUrl = "REDIS_URL"

  func loadOrFatal() -> String {
    guard let string = Environment.get(self.rawValue) else {
      fatalError("\(self.rawValue) not set in environment")
    }

    return string
  }

  func load() throws -> String {
    guard let string = Environment.get(self.rawValue) else {
      throw EnvVarMissingError(name: self.rawValue)
    }

    return string
  }

  struct EnvVarMissingError: LocalizedError {
    let name: String

    var errorDescription: String? {
      "Expected `\(name)` to be present in the environment but it was not"
    }
  }

  struct EnvVarsMissingError: LocalizedError {
    let names: [String]

    var errorDescription: String? {
      return "Expected \(names.map { "`\($0)`"}.joined(separator: ", ")) to be present in the environment but it was not"
    }
  }

  static func ensureAllPresent() throws {
    let names: [String] = Self.allCases
      .compactMap { envVar in
        do {
          _ = try envVar.load()
          return nil
        } catch {
          return envVar.rawValue
        }
      }

    if names.isEmpty {
      return
    }

    throw EnvVarsMissingError(names: names)
  }
}
