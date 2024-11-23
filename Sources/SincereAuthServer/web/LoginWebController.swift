import Vapor

final class LoginWebController {

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
                          appleidSigninNonce: "nonce",
                          isDev: req.application.environment == Environment.development)
    return try await req.view.render("Login/login", login)
  }

  struct LoginView: Codable {
    let appleidSigninClientId: String
    let appleidSigninScope: String
    let appleidSigninRedirectUri: String
    let appleidSigninState: String
    let appleidSigninNonce: String
    let isDev: Bool
  }
  
  func siwaRedirect(req: Request) async throws -> String {
    return "redirect"
  }
}

extension LoginWebController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes.get("login", use: self.login(req:))
    
    routes.post("login", "dev", use: self.devLogin(request:))
    
    // /redirect/siwa
    routes.group("redirect") { redirect in
      redirect.post("siwa", use: self.siwaRedirect)
    }
  }
}
