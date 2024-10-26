import XCTest
import Vapor
import JWTKit
@testable import SincereAuthServer

final class SIWAServerNotificationEncodingTests: XCTestCase {

  var app: Application!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testEncode() throws {
    let notification = SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: "com.mytest.app"),
      iat: IssuedAtClaim(value: Date(timeIntervalSince1970: 1508184845)),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: #"{"type":"consent-revoked","sub":"820417.faa325acbc78e1be1668ba852d492d8a.0219","event_time":1670016125295}"#))

    let jwt: String = try app.jwt.signers.sign(notification)


    let decoded: SIWAServerNotification = try app.jwt.signers.unverified(jwt, as: SIWAServerNotification.self)

    XCTAssertEqual(decoded.iss.value, "https://appleid.apple.com")
    let decodedEvent = try XCTUnwrap(decoded.events.wrapped.consentRevoked)
    XCTAssertEqual(decodedEvent.sub, "820417.faa325acbc78e1be1668ba852d492d8a.0219")
    XCTAssertEqual(decodedEvent.eventTime.value, Date(timeIntervalSince1970: 1670016125295))
  }
}
