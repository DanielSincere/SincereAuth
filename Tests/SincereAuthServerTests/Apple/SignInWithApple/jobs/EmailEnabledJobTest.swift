import Foundation
@testable import SincereAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class EmailEnabledJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()

    try app.resetDatabase()

    self.existingUserID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: existingAppleID)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testUpdateEmail() throws {

    try EmailEnabledJob.updateEmail(
      for: .init(newEmail: "newEmail@example.nyc",
                 appleUserID: existingAppleID),
      logger: Logger(label: String(describing: self)),
      db: app.db(.psql)).wait()

    let updatedSiwa = try XCTUnwrap(SIWAModel.findBy(appleUserId: existingAppleID,
                                                     db: app.db(.psql)).wait())

    XCTAssertEqual(updatedSiwa.email, "newEmail@example.nyc")
  }
}
