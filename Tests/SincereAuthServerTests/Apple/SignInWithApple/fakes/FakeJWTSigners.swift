import Foundation
@testable import SincereAuthServer
import JWTKit

struct FakeJWTSigners: JWTVerifying {

  let stub: Stub

  func verify<Payload>(_ token: String, as payload: Payload.Type) throws -> Payload where Payload : JWTKit.JWTPayload {
    switch stub {
    case .success:
      return (AppleIdentityTokenFixtures.fakeSample.decoded) as! Payload
    case .failure:
      throw UnverifiedError()
    }
  }

  enum Stub {
    case success
    case failure
  }

  struct UnverifiedError: Error { }
}
