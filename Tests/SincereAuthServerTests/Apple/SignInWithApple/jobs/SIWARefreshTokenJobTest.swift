import Foundation
@testable import SincereAuthServer
import XCTest
import Vapor
import JWTKit

final class SIWARefreshTokenJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  func testHitsAppleClientAndOnSuccessUpdatesLastRefreshedTimestamp() async throws {
    let (user, siwa) = try await self.refreshWithApple(
      stubResponse: .decoded(AppleTokenRefreshResponse(
        access_token: "beg510...67Or9",
        expires_in: 3600,
        id_token: "eyJra...96sZg",
        token_type: "Bearer")))

    let attemptedRefreshAt = try XCTUnwrap(siwa.attemptedRefreshAt)
    XCTAssertNearlyNow(attemptedRefreshAt)
    XCTAssertEqual(siwa.attemptedRefreshResult, .success)
    XCTAssertNotNil(siwa.encryptedAppleRefreshToken)
    XCTAssertEqual(user.status, .active)
  }

  func testHitsAppleClientAndOnFailureUpdatesLastRefreshedAndDeactivates() async throws {

    let (user, siwa) = try await self.refreshWithApple(
      stubResponse: .error(AppleErrorResponse(error: "invalid_grant")))
    let attemptedRefreshAt = try XCTUnwrap(siwa.attemptedRefreshAt)
    XCTAssertNearlyNow(attemptedRefreshAt)
    XCTAssertEqual(siwa.attemptedRefreshResult, .failure)
    XCTAssertNil(siwa.encryptedAppleRefreshToken)
    XCTAssertEqual(user.status, .deactivated)
  }

  func testOtherKindsOfErrorsDontDeauthorizeUser() async throws {
    let (user, siwa) = try await self.refreshWithApple(
      stubResponse: .error(.init(error: "other_error")))

    let attemptedRefreshAt = try XCTUnwrap(siwa.attemptedRefreshAt)
    XCTAssertNearlyNow(attemptedRefreshAt)
    XCTAssertEqual(siwa.attemptedRefreshResult, .failure)
    XCTAssertNotNil(siwa.encryptedAppleRefreshToken)
    XCTAssertEqual(user.status, .active)
  }

  func testWhenAppleReturnsAnUnverifiableToken_thenMarkTheFailureButDontDeactivate() async throws {
    let (user, siwa) = try await self.refreshWithApple(
      stubResponse: .decoded(AppleTokenRefreshResponse(
        access_token: "beg510...67Or9",
        expires_in: 3600,
        id_token: "eyJra...96sZg",
        token_type: "Bearer")),
      stubJWTVerification: .failure)

    let attemptedRefreshAt = try XCTUnwrap(siwa.attemptedRefreshAt)
    XCTAssertNearlyNow(attemptedRefreshAt)
    XCTAssertEqual(siwa.attemptedRefreshResult, .failure)
    XCTAssertNotNil(siwa.encryptedAppleRefreshToken)
    XCTAssertEqual(user.status, .active)
  }

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

  private func refreshWithApple(
    stubResponse: AppleResponse<AppleTokenRefreshResponse>,
    stubJWTVerification: FakeJWTSigners.Stub = .success) async throws -> (UserModel, SIWAModel) {
    let maybeModel = try await SIWAModel.findBy(appleUserId: existingAppleID,
                                                db: app.db(.psql)).get()
    let siwa = try XCTUnwrap(maybeModel)

    let client = FakeSIWAClient(eventLoop: app.eventLoopGroup.next(),
                                validateRefreshTokenStub: stubResponse)

    let signers = FakeJWTSigners(stub: stubJWTVerification)

    try await RefreshTokenJob.refreshTokenWithApple(
      siwaID: try siwa.requireID(),
      logger: Logger(label: "test"),
      db: app.db(.psql),
      client: client,
      signers: signers
    )

    let maybeReloadedModel = try await SIWAModel.findBy(
      appleUserId: existingAppleID,
      db: app.db(.psql))
      .get()

    let reloadedSiwa = try XCTUnwrap(maybeReloadedModel)

    let maybeReloadedUser = try await UserModel.findBy(
      id: siwa.$user.id,
      db: app.db(.psql))
      .get()

    let reloadedUser = try XCTUnwrap(maybeReloadedUser)

    return (reloadedUser, reloadedSiwa)
  }
}
