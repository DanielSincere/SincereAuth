import Foundation
import Vapor
@testable import SincereAuthServer

struct FakeSIWAClient: SIWAClient {
  
  let eventLoop: EventLoop
  
  struct StubMissing: Error { }
  
  var validateRefreshTokenStub: AppleResponse<AppleTokenRefreshResponse>?
  func validateRefreshToken(token: String, appId: String) -> NIOCore.EventLoopFuture<AppleResponse<AppleTokenRefreshResponse>> {
    if let stub = validateRefreshTokenStub {
      return eventLoop.makeSucceededFuture(stub)
    } else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
  }
  
  var generateRefreshTokenStub: AppleTokenResponse?
  func generateRefreshToken(code: String, appId: String) -> NIOCore.EventLoopFuture<SincereAuthServer.AppleTokenResponse> {
    if let stub = generateRefreshTokenStub {
      return eventLoop.makeSucceededFuture(stub)
    } else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
  }
  
  func `for`(_ request: Vapor.Request) -> SincereAuthServer.SIWAClient {
    self
  }
}
