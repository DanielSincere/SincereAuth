@testable import FQAuthServer

extension SIWASignUpRepo {


  @discardableResult
  func createTestUser(appleUserId: String = "820417.faa325acbc78e1be1668ba852d492d8a.0219") throws -> UserModel.IDValue {

    let params: Params = .init(
     email: "email@example.com",
     firstName: "First",
     lastName: "Last",
     deviceName: "My Test iPhone",
     method: .siwa(
       appleUserId: appleUserId,
       appleRefreshToken: "fakeToken"))

    return try self.signUp(params).wait()
  }
}