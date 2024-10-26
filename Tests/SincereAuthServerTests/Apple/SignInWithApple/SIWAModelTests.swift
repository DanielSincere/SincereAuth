import Foundation
@testable import SincereAuthServer
import XCTest
import Vapor
import PostgresKit

final class SIWAModelTests: XCTestCase {

  var app: Application!
  var userID: UserModel.IDValue!
  var siwaModel: SIWAModel!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")

    self.siwaModel = try XCTUnwrap(SIWAModel.findBy(userId: userID, db: app.db(.psql)).wait())
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testShouldNotAttemptRefreshWhenNewUser() throws {
    XCTAssertFalse(siwaModel.shouldAttemptRefresh())
  }

  func testShouldNotAttemptRefreshWhenNewUserIsJustUnderOneDayOld() throws {
    XCTAssertFalse(siwaModel.shouldAttemptRefresh(now: Date(timeIntervalSinceNow: 86400 - 60)))
  }

  func testShouldAttemptRefreshWhenNewUserIsOverADayOld() throws {
    XCTAssertTrue(siwaModel.shouldAttemptRefresh(now: Date(timeIntervalSinceNow: 86400 + 60)))
  }
}
