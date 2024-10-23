import XCTest
import Vapor
@testable import SincereAuthServer
import FluentPostgresDriver

final class SIWASignUpRepoTests: XCTestCase {
  
  var app: Application!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.resetDatabase()
  }
    
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  var db: Database {
    app.databases.database(.psql, logger: app.logger, on: app.eventLoopGroup.next())!
  }
  
  func testSignUp() throws {
    let repo = SIWASignUpRepo(logger: app.logger,
                              eventLoop: app.eventLoopGroup.next(),
                              database: db as! SQLDatabase)
    let userID = try repo.signUp(.init(email: "tomato@example.com",
                                       firstName: "First",
                                       lastName: "Last",
                                       deviceName: "device",
                                       roles: ["test", "sample"],
                                       method: .siwa(appleUserId: "AppleUserId",
                                                     appleRefreshToken: "AppleRefresh",
                                                     appId: "com.fullqueuedeveloper.FQAuth")
                                      )).wait()
    
    let siwa = try XCTUnwrap(SIWAModel.findBy(appleUserId: "AppleUserId", db: self.db).wait())
    let user = try XCTUnwrap(UserModel.find(userID, on: self.db).wait())
    
    XCTAssertEqual(user.firstName, "First")
    XCTAssertEqual(user.lastName, "Last")
    XCTAssertEqual(user.registrationMethod, .siwa)
    XCTAssertEqual(user.status, .active)
    XCTAssertTrue(user.roles.contains("test"))
    XCTAssertTrue(user.roles.contains("sample"))
    XCTAssertNearlyNow(user.createdAt)
    XCTAssertNearlyNow(user.updatedAt)
    
    XCTAssertEqual(siwa.email, "tomato@example.com")
    XCTAssertNearlyNow(siwa.createdAt)
    XCTAssertNearlyNow(siwa.updatedAt)
    XCTAssertEqual(siwa.attemptedRefreshAt, nil)
    XCTAssertEqual(siwa.appleUserId, "AppleUserId")
    XCTAssertEqual(siwa.unsealedAppleRefreshToken(), "AppleRefresh")
  }
}
