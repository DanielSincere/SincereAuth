import XCTest
import Vapor
@testable import SincereAuthServer

final class SIWAClientTests: XCTestCase {
  
  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  func testClientSecret() throws {
    let clientSecret = SIWAClientSecret(clientId: try EnvVars.appleAppId.load(), teamId: try EnvVars.appleTeamId.load())
    XCTAssertEqual(clientSecret.iss.value, try EnvVars.appleTeamId.load())
    XCTAssertEqual(clientSecret.iat.value.timeIntervalSinceReferenceDate, Date().timeIntervalSinceReferenceDate, accuracy: 10)
    XCTAssertEqual(clientSecret.exp.value.timeIntervalSinceReferenceDate, Date(timeIntervalSinceNow: .oneDay).timeIntervalSinceReferenceDate, accuracy: 10)
    XCTAssertEqual(clientSecret.aud.value.count, 1)
    
    let firstAudience = try XCTUnwrap(clientSecret.aud.value.first)
    XCTAssertEqual(firstAudience, "https://appleid.apple.com")
    XCTAssertEqual(clientSecret.sub.value, try EnvVars.appleAppId.load())
    
    try clientSecret.verify(using: try app.jwt.signers.require(kid: .appleServicesKey))
  }
  
  func testRequestSentToApple() throws {
    let httpClient = FakeClient(stubbedResponse: AppleFixtures.successfulSiwaSignUpResponse, eventLoop: app.eventLoopGroup.next())
    let siwaClient = LiveSIWAClient(signers: app.jwt.signers,
                                    client: httpClient,
                                    logger: app.logger)
    
    let _ = try siwaClient.generateRefreshToken(code: "code123", appId: try EnvVars.appleAppId.load()).wait()
    
    let request: ClientRequest = try XCTUnwrap(httpClient.receivedRequest)
    XCTAssertEqual(request.url.string, "https://appleid.apple.com/auth/token")
    XCTAssertEqual(request.headers, HTTPHeaders([("content-type", "application/x-www-form-urlencoded; charset=utf-8")]))
    
    let urlEncodedFormString = try XCTUnwrap(request.body?.string)
    let body = try URLEncodedFormDecoder().decode(AppleAuthTokenBody.self, from: urlEncodedFormString)
    XCTAssertEqual(body.grant_type, "authorization_code")
    XCTAssertEqual(body.client_id, try EnvVars.appleAppId.load())
    XCTAssertEqual(body.code, "code123")
    XCTAssertNil(body.redirect_uri)
    XCTAssertNil(body.refresh_token)
    
    let clientSecret = try app.jwt.signers.verify(body.client_secret, as: SIWAClientSecret.self)
    XCTAssertEqual(clientSecret.iss.value, try EnvVars.appleTeamId.load())
    XCTAssertEqual(clientSecret.iat.value.timeIntervalSinceReferenceDate, Date().timeIntervalSinceReferenceDate, accuracy: 10)
    XCTAssertEqual(clientSecret.exp.value.timeIntervalSinceReferenceDate, Date(timeIntervalSinceNow: .oneDay).timeIntervalSinceReferenceDate, accuracy: 10)
    XCTAssertEqual(clientSecret.aud.value.count, 1)
    
    let firstAudience = try XCTUnwrap(clientSecret.aud.value.first)
    XCTAssertEqual(firstAudience, "https://appleid.apple.com")
    XCTAssertEqual(clientSecret.sub.value, try EnvVars.appleAppId.load())
  }
  
  class FakeClient: Client {
    var receivedRequest: ClientRequest?
    
    let stubbedResponse: ClientResponse
    var eventLoop: NIOCore.EventLoop
    init(stubbedResponse: ClientResponse, eventLoop: NIOCore.EventLoop) {
      self.stubbedResponse = stubbedResponse
      self.eventLoop = eventLoop
    }
    
    func delegating(to eventLoop: NIOCore.EventLoop) -> Vapor.Client {
      self.eventLoop = eventLoop
      return self
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
      self.receivedRequest = request
      return eventLoop.makeSucceededFuture(stubbedResponse)
    }
  }
}
