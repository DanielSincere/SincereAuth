import Vapor

extension LoginWebController {
  
  struct DevLoginForm: Content {
    let firstName: String
    let lastName: String
  }
  
  func devLogin(request: Request) async throws -> Response {
    guard request.application.environment == Environment.development else {
      throw Abort(.unauthorized)
    }
    
    let form = try request.content.decode(DevLoginForm.self)
    let user = try await self.findOrCreateUser(request: request, form: form)
    request.auth.login(user)
    return request.redirect(to: "/home")
  }
  
  private func findOrCreateUser(request: Request, form: DevLoginForm) async throws -> UserModel {
    let maybeUser = try await UserModel.findBy(
      firstName: form.firstName,
      lastName: form.lastName,
      db: request.db).get()
    
    if let user = maybeUser {
      return user
    } else {
      let user = UserModel(firstName: form.firstName, lastName: form.lastName, registrationMethod: .dev)
      try await user.create(on: request.db)
      return user
    }
  }
}
