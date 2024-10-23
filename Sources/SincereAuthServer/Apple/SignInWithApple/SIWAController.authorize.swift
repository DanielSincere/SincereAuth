import Vapor
import JWTKit

extension SIWAController {
  
  struct AuthorizeBody: Content {
    let appleIdentityToken: String
    let authorizationCode: String
    let bundleId: String
    let deviceName: String
    let firstName: String?
    let lastName: String?
  }
  
  struct UnknownBundleIdError: LocalizedError {
    var errorDescription: String? {
      "Unknown bundle ID is not supported by this server. Please see documentation if you're the dev"
    }
  }
  
  func authorize(request: Request) -> EventLoopFuture<AuthResponse> {
    
    return AuthorizeBody.decodeRequest(request)
      .guard({ body in
        let maybeAdditionalBundleIdsString: String = (try? EnvVars.additionalAppleAppIds.load()) ?? ""
        let additionalIds: [String] = maybeAdditionalBundleIdsString.split(separator: " ").map(String.init)
        let allValidIds = additionalIds + [EnvVars.appleAppId.loadOrFatal()]
        return allValidIds.contains(body.bundleId)
      }, else: UnknownBundleIdError())
      .flatMap { authorizeBody in
        let verifier = request.services.siwaVerifier
        return verifier.verify(authorizeBody.appleIdentityToken,
                               bundleId: authorizeBody.bundleId)
        .flatMap { (appleIdentityToken: AppleIdentityToken) in
          return request.services.siwaClient
            .generateRefreshToken(code: authorizeBody.authorizationCode, appId: authorizeBody.bundleId)
            .flatMap { appleTokenResponse in
              return UserModel.findByAppleUserId(appleIdentityToken.subject.value, db: request.db)
                .flatMap { maybeUser in
                  if let userModel = maybeUser {
                    return self.signIn(
                      authorizeBody: authorizeBody,
                      userModel: userModel,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      request: request)
                  } else {
                    return self.signUp(
                      authorizeBody: authorizeBody,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      request: request)
                  }
                }
            }
        }
      }
  }
  
  private func requireEmail(appleIdentityToken: AppleIdentityToken, eventLoop: EventLoop) -> EventLoopFuture<String> {
    if let email = appleIdentityToken.email {
      return eventLoop.makeSucceededFuture(email)
    }
    
    return eventLoop.makeFailedFuture(Abort(.badRequest,
                                            headers: HTTPHeaders(),
                                            reason: "Email missing from Apple token. Visit https://appleid.apple.com and sign out of our app. Then try again.",
                                            identifier: "email.missing",
                                            suggestedFixes: ["Visit https://appleid.apple.com and sign out of our app. Then try again."]))
  }
  
  private func signIn(authorizeBody: AuthorizeBody,
                      userModel: UserModel,
                      appleIdentityToken: AppleIdentityToken,
                      appleTokenResponse: AppleTokenResponse,
                      request: Request) -> EventLoopFuture<AuthResponse> {
    guard let siwa = userModel.$siwa.wrappedValue, let userId = userModel.id else {
      return request.eventLoop.makeFailedFuture(Abort(.forbidden))
    }
    
    siwa.encryptedAppleRefreshToken = DBSeal().seal(string: appleTokenResponse.refresh_token)
    return siwa.update(on: request.db(.psql)).flatMap { _ in
      return AuthHelper(request: request)
        .login(userId: userId,
               firstName: userModel.firstName,
               lastName: userModel.lastName,
               deviceName: authorizeBody.deviceName,
               roles: userModel.roles)
    }
  }
  
  private func signUp(authorizeBody: AuthorizeBody,
                      appleIdentityToken: AppleIdentityToken,
                      appleTokenResponse: AppleTokenResponse,
                      request: Request) -> EventLoopFuture<AuthResponse> {
    
    self.requireEmail(appleIdentityToken: appleIdentityToken, eventLoop: request.eventLoop)
      .flatMap { email in
        guard let firstName = authorizeBody.firstName,
              let lastName = authorizeBody.lastName else {
          return request.eventLoop.makeFailedFuture(Abort(.badRequest,
                                                          headers: HTTPHeaders(),
                                                          reason: "Name missing. Visit https://appleid.apple.com and sign out of our app. Then try again.",
                                                          identifier: "name.missing",
                                                          suggestedFixes: ["Visit https://appleid.apple.com and sign out of our app. Then try again."]))
        }
        
        return SIWASignUpRepo(request: request)
          .signUp(.init(email: email,
                        firstName: firstName,
                        lastName: lastName,
                        deviceName: authorizeBody.deviceName,
                        roles: [],
                        method: .siwa(
                          appleUserId: appleIdentityToken.subject.value,
                          appleRefreshToken: appleTokenResponse.refresh_token,
                          appId: authorizeBody.bundleId)
                       ))
          .flatMap { userId in
            AuthHelper(request: request)
              .login(userId: userId,
                     firstName: firstName,
                     lastName: lastName,
                     deviceName: authorizeBody.deviceName,
                     roles: [])
          }
      }
  }
}
