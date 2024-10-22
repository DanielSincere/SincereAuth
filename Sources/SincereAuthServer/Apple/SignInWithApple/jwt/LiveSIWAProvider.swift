import Vapor
import JWTKit

struct LiveSIWAVerifierProvider: SIWAVerifierProvider {
  func `for`(_ request: Vapor.Request) -> SIWAVerifier {
    LiveSIWAVerifier(request: request)
  }
}

struct LiveSIWAVerifier: SIWAVerifier {
  
  let apple: Request.JWT.Apple
  init(request: Request) {
    self.apple = request.jwt.apple
  }
  
  func verify(_ string: String, bundleId: String) -> EventLoopFuture<AppleIdentityToken> {
    self.apple.verify(string, applicationIdentifier: bundleId)
  }
}
