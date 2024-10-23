import Vapor

final class LoginController {

  func login(req: Request) async throws -> View {
    guard let redirect = URL(string: "login/redirect", relativeTo: URL(string: EnvVars.websiteURL.loadOrFatal())) else {
      struct WebsiteURLNotConfigured: LocalizedError {
        var errorDescription: String? = "Website URL not configured in env var WEBSITE_URL"
      }
      throw WebsiteURLNotConfigured()
    }
    let login = LoginView(appleidSigninClientId: try EnvVars.websiteAppleAppId.load(),
                          appleidSigninScope: "code id_token name email",
                          appleidSigninRedirectUri: redirect.absoluteString,
                          appleidSigninState: "state",
                          appleidSigninNonce: "nonce")
    return try await req.view.render("Login/login", login)
  }

  struct LoginView: Codable {
    let appleidSigninClientId: String
    let appleidSigninScope: String
    let appleidSigninRedirectUri: String
    let appleidSigninState: String
    let appleidSigninNonce: String
  }
  
  func siwaRedirect(req: Request) async throws -> String {
    return "redirect"
  }
}

extension LoginController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes.get("login", use: self.login(req:))
    
    // /redirect/siwa
    routes.group("redirect") { redirect in
      redirect.post("siwa", use: self.siwaRedirect)
    }
  }
}
