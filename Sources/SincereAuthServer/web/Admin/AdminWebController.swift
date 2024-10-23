import Vapor
import SincereAuthMiddleware

final class AdminWebController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes
      .grouped(SincereAuthMiddleware(requiredRole: "admin"))
      .group("admin") { admin in
        admin.get("list-users", use: self.listUsers(req:))
      }
  }
}
