import Foundation
@testable import SincereAuthServer
import XCTest
import Vapor
import PostgresKit

final class SIWAReadyForReverifyRepoTests: XCTestCase {

  var app: Application!
  var userID: UserModel.IDValue!
  var siwaModel: SIWAModel!

  let appleUserId = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  var repo: SIWAReadyForReverifyRepo!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: appleUserId)

    self.siwaModel = try XCTUnwrap(SIWAModel.findBy(userId: userID, db: app.db(.psql)).wait())

    self.repo = SIWAReadyForReverifyRepo(application: self.app)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testShouldNotRefreshWhenSIWAisInitialAndEncryptedAppleRefreshTokenIsNil() async throws {
    siwaModel.encryptedAppleRefreshToken = nil
    siwaModel.attemptedRefreshResult = .initial
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotRefreshWhenUserIsAlreadyDeactivatedAndSIWAisInitial() async throws {
    let user = try XCTUnwrap(UserModel.findByAppleUserId(appleUserId, db: app.db(.psql)).wait())
    user.status = .deactivated
    try user.save(on: app.db(.psql)).wait()

    siwaModel.attemptedRefreshResult = .initial
    siwaModel.attemptedRefreshAt = nil
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenUserIsAlreadyDeactivated() async throws {
    let user = try XCTUnwrap(UserModel.findByAppleUserId(appleUserId, db: app.db(.psql)).wait())
    user.status = .deactivated
    try user.save(on: app.db(.psql)).wait()

    siwaModel.attemptedRefreshResult = .success
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenSIWAHasNoRefreshToken() async throws {
    siwaModel.encryptedAppleRefreshToken = nil
    siwaModel.attemptedRefreshResult = .success
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenNewUser() async throws {
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenNewUserIsJustUnderOneDayOld() async throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 + 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldAttemptRefreshWhenNewUserIsOverOneDayOld() async throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 - 60 )
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndAttemptedRefreshIsEmpty() async throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndAttemptedRefreshIsEmpty() async throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndLatestRefreshWasOverADayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndLatestRefreshWasOverADayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldNotAttemptWhenSuccessAndLatestRefreshWasUnderDayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptWhenFailureAndLatestRefreshWasUnderDayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }
}
