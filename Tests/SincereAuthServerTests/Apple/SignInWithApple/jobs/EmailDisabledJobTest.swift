import Foundation
@testable import SincereAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class EmailDisabledJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  let existingEmail: String = "tomato@example.nyc"
  let existingAppleID: String = "302024.1951936c61fa47debb2b076e6896ccc1.1949"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()

    try app.resetDatabase()

    self.existingUserID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: existingAppleID, email: existingEmail)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testDoesntRemovesEmail_emailDoesntMatchExisting() throws {
    try EmailDisabledJob.removeEmail(
      for: .init(email: "arst", appleUserID: existingAppleID),
      logger: Logger(label: String(describing: self)),
      db: app.db(.psql)).wait()


    let siwa = try XCTUnwrap(SIWAModel.findBy(appleUserId: existingAppleID, db: app.db(.psql)).wait())
    XCTAssertEqual(siwa.email, existingEmail)
  }

  func testRemovesEmail_whenEmailMatches() throws {
    try EmailDisabledJob.removeEmail(
      for: .init(email: existingEmail, appleUserID: existingAppleID),
      logger: Logger(label: String(describing: self)),
      db: app.db(.psql)).wait()


    let siwa = try XCTUnwrap(SIWAModel.findBy(appleUserId: existingAppleID, db: app.db(.psql)).wait())
    XCTAssertNil(siwa.email)
  }
}
