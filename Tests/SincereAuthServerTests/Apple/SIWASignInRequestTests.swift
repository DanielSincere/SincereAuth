@testable import SincereAuthServer
import SincereAuthMiddleware
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignInRequestTests: XCTestCase {
  
  var app: Application!
  var existingUserID: UserModel.IDValue!
  var existingUser: UserModel!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.resetDatabase()
    
    let signUpParams = SIWASignUpRepo.Params(email: "test@example.com",
                                             firstName: "First",
                                             lastName: "Last",
                                             deviceName: "iPhone",
                                             roles: [],
                                             method: .siwa(appleUserId: existingAppleID,
                                                           appleRefreshToken: "AppleRefreshToken"))
    
    self.existingUserID = try SIWASignUpRepo(application: app).signUp(signUpParams)
      .wait()
    self.existingUser = try UserModel.find(existingUserID, on: app.db(.psql))
      .wait()

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
  
  func testSignIn() throws {
    let requestBody = """
      {
        "appleIdentityToken": "FakeToken",
        "authorizationCode": "abcde",
        "deviceName": "iPhone",
        "bundleId": "com.fullqueuedeveloper.FQAuth"
      }
    """
    
    try app.test(.POST, "/api/siwa/authorize",
                 headers: HTTPHeaders([("Content-Type", "application/json")]),
                 body: ByteBuffer(string: requestBody)) { response in
      XCTAssertEqual(response.status, .ok)
      
      let maybeUser = try UserModel.findByAppleUserId(existingAppleID,
                                                      db: app.db(.psql)).wait()
      
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(existingUser.firstName, user.firstName)
      XCTAssertEqual(user.firstName, "First")
      XCTAssertEqual(user.lastName, "Last")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 1)
      let refreshToken = try XCTUnwrap(refreshTokens.first)
      XCTAssertEqual(refreshToken.$user.id, user.id)
      XCTAssertEqual(refreshToken.deviceName, "iPhone")
      XCTAssertNearlyNow(refreshToken.createdAt)
      XCTAssertNearlyEqual(refreshToken.expiresAt,
                           Date(timeIntervalSinceNow: AuthConstant.refreshTokenLifetime))
      
      let authResponse = try response.content.decode(AuthResponse.self)
      let sessionToken = try app.jwt.signers.verify(authResponse.accessToken, as: SincereAuthSessionToken.self)
      XCTAssertEqual(sessionToken.iss.value, try EnvVars.selfIssuerId.load())
      XCTAssertEqual(sessionToken.userID, user.id)
      XCTAssertEqual(sessionToken.deviceName, "iPhone")
      XCTAssertNearlyNow(sessionToken.iat.value)
      XCTAssertEqual(sessionToken.roles, [])
    }
  }
}
