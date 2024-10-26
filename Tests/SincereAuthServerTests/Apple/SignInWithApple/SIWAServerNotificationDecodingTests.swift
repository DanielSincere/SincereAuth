import XCTest
import Vapor
@testable import SincereAuthServer

final class SIWAServerNotificationDecodingTests: XCTestCase {

  func testDocumentationExample() throws {
    // The example in the documentation does not match JSON posted to my server from Apple. The example has been adjusted

    let json = #"""
        {
            "iss": "https://appleid.apple.com",
            "aud": "com.mytest.app",
            "iat": 1508184845,
            "jti": "abede67890",
            "events": "{\"type\":\"consent-revoked\",\"sub\":\"820417.faa325acbc78e1be1668ba852d492d8a.0219\",\"event_time\":1670016125295}"
        }
        """#

    let notification = try JSONDecoder().decode(SIWAServerNotification.self, from: json.data(using: .utf8)!)
    XCTAssertNoThrow(try notification.aud.verifyIntendedAudience(includes: "com.mytest.app"))

    let consentRevoked = try XCTUnwrap(notification.events.wrapped.consentRevoked)

    XCTAssertEqual(consentRevoked.sub.value, "820417.faa325acbc78e1be1668ba852d492d8a.0219")
  }

  func testFixture() throws {
    let app: Application = Application(.testing)
    defer {
      app.shutdown()
    }

    try app.useAppleJWKS()

    let body = try JSONDecoder().decode(SIWAController.NotifyBody.self, from: AppleFixtures.siwaNotificationBody.data(using: .utf8)!)
    let notification = try app.jwt.signers.unverified(body.payload, as: SIWAServerNotification.self)

    XCTAssertEqual(notification.iss, "https://appleid.apple.com")
    XCTAssertNoThrow(try notification.aud.verifyIntendedAudience(includes: "com.fullqueuedeveloper.FQAuthSampleiOSApp"))

    let consentRevoked = try XCTUnwrap(notification.events.wrapped.consentRevoked)
    XCTAssertEqual(consentRevoked.sub.value, "002024.1951936c61fa47debb2b076e6896ccc1.1949")
  }
}
