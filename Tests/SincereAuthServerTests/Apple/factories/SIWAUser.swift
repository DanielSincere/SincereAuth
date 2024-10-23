@testable import SincereAuthServer

extension SIWASignUpRepo {

  @discardableResult
  func createTestUser(
    appleUserId: String = "820417.faa325acbc78e1be1668ba852d492d8a.0219",
    email: String = "email@example.com")
  throws -> UserModel.IDValue {

    let params: Params = .init(
     email: email,
     firstName: "First",
     lastName: "Last",
     deviceName: "My Test iPhone",
     roles: ["test", "sample"],
     method: .siwa(
       appleUserId: appleUserId,
       appleRefreshToken: "fakeToken",
       appId: "com.fullqueuedeveloper.FQAuth"))

    return try self.signUp(params).wait()
  }
}
