import Foundation
import XCTest
@testable import SincereAuthServer
import Vapor

final class SIWADeactivateUserRepoTests: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  var existingSiwa: SIWAModel!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  func testDeactivate() async throws {

    try await SIWADeactivateUserRepo(application: app)
      .deactivate(siwaID: try existingSiwa.requireID(), andRecordRefreshTokenFailure: false)

    let (user, siwa) = try await self.load(userID: existingUserID,
                                           siwaID: try existingSiwa.requireID())

    XCTAssertEqual(user.status, .deactivated)
    XCTAssertNil(siwa.encryptedAppleRefreshToken)
  }

  func testDeactivateAndRecordRefreshTokenFailure() async throws {

    try await SIWADeactivateUserRepo(application: app)
      .deactivate(siwaID: try existingSiwa.requireID(), andRecordRefreshTokenFailure: true)

    let (user, siwa) = try await self.load(userID: existingUserID,
                                           siwaID: try existingSiwa.requireID())

    XCTAssertEqual(user.status, .deactivated)
    XCTAssertNil(siwa.encryptedAppleRefreshToken)
    XCTAssertEqual(siwa.attemptedRefreshResult, .failure)
  }

  func load(userID: UserModel.IDValue, siwaID: SIWAModel.IDValue) async throws -> (UserModel, SIWAModel) {
    let maybeReloadedModel = try await SIWAModel.findBy(
      appleUserId: existingAppleID,
      db: app.db(.psql))
      .get()

    let reloadedSiwa = try XCTUnwrap(maybeReloadedModel)

    let maybeReloadedUser = try await UserModel.findBy(
      id: existingUserID,
      db: app.db(.psql))
      .get()

    let reloadedUser = try XCTUnwrap(maybeReloadedUser)

    return (reloadedUser, reloadedSiwa)
  }

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.existingUserID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: existingAppleID)
    let maybeSiwa = try SIWAModel.findBy(appleUserId: existingAppleID,
                                         db: app.db(.psql)).wait()
    self.existingSiwa = try XCTUnwrap(maybeSiwa)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}
