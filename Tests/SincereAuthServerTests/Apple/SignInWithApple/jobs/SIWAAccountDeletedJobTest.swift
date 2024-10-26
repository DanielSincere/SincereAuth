import Foundation
@testable import SincereAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class SIWAAccountDeletedJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  
  var existingSIWAModel: SIWAModel!
  let existingAppleID: String = "999024.1951936c61fa47debb2b076e6896ccc1.1949"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()

    try app.resetDatabase()

    self.existingUserID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: existingAppleID)

    self.existingSIWAModel = try SIWAModel
      .findBy(appleUserId: existingAppleID, db: app.db(.psql))
      .wait()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testAccountDeletedNoticationDeletesSIWAAccountAndDeactivatesUser() throws {

    try SIWAAccountDeletedJob.deleteSIWAAccount(appleUserID: existingAppleID,
                                            logger: Logger(label: String(describing: self)),
                                            db: app.db(.psql))
    .wait()

    let updatedUser = try XCTUnwrap(UserModel.find(self.existingUserID, on: app.db(.psql)).wait())

    XCTAssertEqual(updatedUser.status, .deactivated)

    let updatedSIWAModel = try SIWAModel.find(existingSIWAModel.id, on: app.db(.psql)).wait()
    XCTAssertNil(updatedSIWAModel)

    XCTAssertNil(try SIWAModel.findBy(appleUserId: existingAppleID, db: app.db(.psql)).wait())
  }
}
