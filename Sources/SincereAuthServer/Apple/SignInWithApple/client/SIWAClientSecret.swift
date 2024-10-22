import JWT
import Foundation

struct SIWAClientSecret: JWTPayload {
  let iss: IssuerClaim
  let iat: IssuedAtClaim
  let exp: ExpirationClaim
  let aud: AudienceClaim
  let sub: SubjectClaim
  
  init(clientId: String, teamId: String) {
    iss = .init(value: teamId)
    iat = .init(value: Date())
    exp = .init(value: Date(timeIntervalSinceNow: .oneDay))
    aud = .init(value: "https://appleid.apple.com")
    sub = .init(value: clientId)
  }
  
  /*
   "iss": "DEF123GHIJ",
   "iat": 1437179036,
   "exp": 1493298100,
   "aud": "https://appleid.apple.com",
   "sub": "com.mytest.app"
   */
  
  func verify(using signer: JWTSigner) throws {
    try self.exp.verifyNotExpired()
    try self.aud.verifyIntendedAudience(includes: "https://appleid.apple.com")
    
    guard try EnvVars.appleTeamId.load() == self.iss.value else {
      throw Errors.issuerMismatch(actual: self.iss.value)
    }
    
    guard try EnvVars.appleAppId.load() == self.sub.value else {
      throw Errors.subjectMismatch(actual: self.sub.value)
    }
  }
  
  enum Errors: Error, LocalizedError {
    
    case subjectMismatch(actual: String)
    case issuerMismatch(actual: String)
    
    var errorDescription: String? {
      switch self {
      case .subjectMismatch(actual: let actual):
        return "Apple JWT failed verification. Subject mismatch: \(actual)"
      case .issuerMismatch(actual: let actual):
        return "Apple JWT failed verification. Issuer mismatch: \(actual)"
      }
    }
  }
}

