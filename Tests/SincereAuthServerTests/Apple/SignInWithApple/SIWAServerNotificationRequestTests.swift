@testable import SincereAuthServer
import XCTest
import Foundation
import Vapor
import JWTKit
import Queues

final class SIWAServerNotificationRequestTests: XCTestCase {

  let appleUserId = "820417.faa325acbc78e1be1668ba852d492d8a.0219"

  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
    try app.resetQueue()

    try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: appleUserId)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testConsentRevoked() throws {

    let notification = try buildNotification(for: """
      {
        \"type\":\"consent-revoked\",
        \"sub\":\"\(appleUserId)\",
        \"event_time\":1670016125295
      }
      """)

    try postNotification(notification, callback: { (jobName, payload: String) in
      XCTAssertEqual(jobName, "ConsentRevokedJob")
      XCTAssertEqual(payload, appleUserId)
    })
  }

  func testAccountDelete() throws {
    let notification = try buildNotification(for: """
      {
        \"type\":\"account-delete\",
        \"sub\":\"\(appleUserId)\",
        \"event_time\":1670016125295
      }
      """)

    try postNotification(notification) { (jobName, payload: String) in
      XCTAssertEqual(jobName, "SIWAAccountDeletedJob")
      XCTAssertEqual(payload, appleUserId)
    }
  }

  func testEmailEnabled() throws {
    let notification = try buildNotification(for: """
      {
        \"type\":\"email-enabled\",
        \"sub\":\"\(appleUserId)\",
        \"event_time\":1673016125295,
        \"email\": "new@example.nyc",
        \"is_private_email\": "true"
      }
      """)

    try postNotification(notification) { (jobName,
                                          payload: EmailEnabledJob.Payload) in

      XCTAssertEqual(jobName, "EmailEnabledJob")
      XCTAssertEqual(payload.appleUserID, appleUserId)
      XCTAssertEqual(payload.newEmail, "new@example.nyc")
    }
  }

  func testEmailDisabled() throws {
    let notification = try buildNotification(for: """
      {
        \"type\":\"email-disabled\",
        \"sub\":\"\(appleUserId)\",
        \"event_time\":1673016125295,
        \"email\": "disabled@example.nyc",
        \"is_private_email\": "true"
      }
      """)

    try postNotification(notification) { (jobName: String,
                                          payload: EmailDisabledJob.Payload) in

      XCTAssertEqual(jobName, "EmailDisabledJob")
      XCTAssertEqual(payload.appleUserID, appleUserId)
      XCTAssertEqual(payload.email, "disabled@example.nyc")
    }
  }

  private func postNotification<T: Decodable>(_ notification: SIWAServerNotification,
                                              file: StaticString = #filePath,
                                              line: UInt = #line,
                                              callback: (String, T) throws -> ()) throws {
    let jwt: String = try app.jwt.signers.sign(notification)
    let notifyBody = SIWAController.NotifyBody(payload: jwt)
    let notificationBodyJson = try JSONEncoder().encode(notifyBody)


    _ = try app.jwt.signers.verify(jwt, as: SIWAServerNotification.self)
    try app.test(.POST, "/api/siwa/notify",
                 headers: HTTPHeaders([("content-type", "application/json")]),
                 body: ByteBuffer(data: notificationBodyJson)) { response in

      XCTAssertEqual(response.status, .ok, file: file, line: line)

      let (jobName, payload) = try app.queues.queue.nextPayload(as: T.self)
      try callback(jobName, payload)
    }
  }

  private func buildNotification(for event: String) throws -> SIWAServerNotification {
    SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: try EnvVars.appleAppId.load()),
      iat: IssuedAtClaim(value: Date()),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: event))
  }
}
