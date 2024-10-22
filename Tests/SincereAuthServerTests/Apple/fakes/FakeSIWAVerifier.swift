import Foundation
import Vapor
@testable import SincereAuthServer
import JWT

struct FakeSIWAVerifier: SIWAVerifier, SIWAVerifierProvider {
  let eventLoop: EventLoop
  
  struct StubMissing: Error { }
  
  var verifyStub: AppleIdentityToken?
  func verify(_ string: String, bundleId: String) -> NIOCore.EventLoopFuture<JWTKit.AppleIdentityToken> {
    guard let stub = verifyStub else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
    
    return eventLoop.makeSucceededFuture(stub)
  }
  
  func `for`(_ request: Vapor.Request) -> SincereAuthServer.SIWAVerifier {
    FakeSIWAVerifier(eventLoop: request.eventLoop, verifyStub: verifyStub)
  }
}

extension FakeSIWAVerifier {

  init(eventLoop: EventLoop, appleTokenResponse: String) throws {
    self.eventLoop = eventLoop
    let tokenResponse = try JSONDecoder().decode(AppleTokenResponse.self, from: ByteBuffer(string: AppleFixtures.successfulSiwaSignInBody))

    let stub = try JWTSigners().unverified(tokenResponse.id_token,as: AppleIdentityToken.self)
    self.verifyStub = stub
  }
}
