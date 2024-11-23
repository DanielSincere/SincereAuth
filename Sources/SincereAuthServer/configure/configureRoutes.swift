import Vapor
import JWT
import SincereAuthMiddleware

extension Application {

  func configureRoutes() throws {
   
    self.get("healthy") { req in
      return "healthy"
    }
      
    self.get("") { req in
      req.view.render("welcome")
    }

    let apiRoutes = self.grouped("api")
    try apiRoutes.register(collection: JWKSController())
    try apiRoutes.register(collection: SIWAController())
    try apiRoutes.register(collection: RefreshTokenController())
    try apiRoutes.register(collection: UserController())

    try self.register(collection: LoginWebController())
    try self.register(collection: AdminWebController())
    try self.register(collection: HomeWebController())
  }
}
