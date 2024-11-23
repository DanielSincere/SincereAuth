import Vapor

final class HomeWebController: RouteCollection {
  func home(req: Request) async throws -> View {
    return try await req.view.render("home")
  }
  
  func logout(req: Request) async throws -> Response {
    req.auth.logout(UserModel.self)
    return req.redirect(to: "/")
  }
  
  func boot(routes: any RoutesBuilder) throws {
    let protected = routes.grouped([
      UserModel.sessionAuthenticator(),
      UserModel.guardMiddleware(),
    ])
    
    protected.get("home", use: home(req:))
    protected.get("logout", use: logout(req:))
  }
}
