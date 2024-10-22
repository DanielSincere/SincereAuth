@testable import SincereAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignUpRequestTests: XCTestCase {

  var app: Application!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.resetDatabase()
    
    app.services.siwaVerifierProvider.use { application in
      try! FakeSIWAVerifier(eventLoop: application.eventLoopGroup.next(), appleTokenResponse: AppleFixtures.successfulSiwaSignInBody)
    }
    
    app.services.siwaClient.use { application in
     FakeSIWAClient(eventLoop: application.eventLoopGroup.next(),
                    generateRefreshTokenStub: .meaninglessStub)
    }
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testSignUp() throws {
    let requestBody = """
      {
        "appleIdentityToken": "FakeToken",
        "authorizationCode": "abcde",
        "deviceName": "iPhone",
        "firstName": "Nimesh",
        "lastName": "Patel",
        "bundleId": "com.fullqueuedeveloper"
      }
    """
    
    try app.test(.POST, "/api/siwa/authorize",
                 headers: HTTPHeaders([("Content-Type", "application/json")]),
                 body: ByteBuffer(string: requestBody)) { response in
      XCTAssertEqual(response.status, .ok)
      
      let maybeUser = try UserModel.findByAppleUserId("002024.1951936c61fa47debb2b076e6896ccc1.1949",
                                                      db: app.db(.psql)).wait()
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(user.firstName, "Nimesh")
      XCTAssertEqual(user.lastName, "Patel")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let maybeSiwa = try SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949", db: app.db(.psql)).wait()
      let siwa = try XCTUnwrap(maybeSiwa)
      let email = try XCTUnwrap(siwa.email)
      XCTAssertTrue(email.starts(with: "fullqueue"))
      XCTAssertTrue(siwa.isActive)
      XCTAssertNearlyNow(siwa.createdAt)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 1)
      
      let refreshToken = try XCTUnwrap(refreshTokens.first)
      XCTAssertEqual(refreshToken.deviceName, "iPhone")
      XCTAssertEqual(refreshToken.$user.id, try user.requireID())
      XCTAssertNearlyNow(refreshToken.createdAt)
      XCTAssertNearlyEqual(refreshToken.expiresAt,
                     Date(timeIntervalSinceNow: AuthConstant.refreshTokenLifetime))
    }
  }
}
