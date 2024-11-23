import FluentPostgresDriver
import Vapor

extension UserModel {
  static func findByEmail(_ email: String, registrationMethod: RegistrationMethod, db: Database) -> EventLoopFuture<UserModel?> {
    switch registrationMethod {
    case .dev:
      return db.eventLoop.makeSucceededFuture(nil)
    case .siwa:
      return UserModel.query(on: db)
        .filter(\UserModel.$registrationMethod == registrationMethod)
        .join(SIWAModel.self, on: \SIWAModel.$user.$id == \UserModel.$id)
        .filter(SIWAModel.self, \SIWAModel.$email == email)
        .first()
    }
  }

  static func findByAppleUserId(_ identifier: String, db: Database) -> EventLoopFuture<UserModel?> {
    UserModel.query(on: db)
      .join(SIWAModel.self, on: \SIWAModel.$user.$id == \UserModel.$id)
      .filter(SIWAModel.self, \SIWAModel.$appleUserId == identifier)
      .with(\UserModel.$siwa)
      .first()
  }

  static func findBy(firstName: String, lastName: String, db: Database) -> EventLoopFuture<UserModel?> {
    UserModel.query(on: db)
      .filter(UserModel.self, \UserModel.$firstName == firstName)
      .filter(UserModel.self, \UserModel.$lastName == lastName)
      .first()
  }
  
  static func findBy(id: UserModel.IDValue, db: Database) -> EventLoopFuture<UserModel?> {
    UserModel
      .query(on: db)
      .filter(\.$id, .equal, id)
      .first()
  }
}
