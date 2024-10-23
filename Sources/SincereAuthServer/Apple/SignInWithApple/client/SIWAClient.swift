import Vapor
import JWTKit

public protocol SIWAClient {
  func `for`(_ request: Request) -> SIWAClient
  func validateRefreshToken(token: String, appId: String) -> EventLoopFuture<AppleResponse<AppleTokenRefreshResponse>>
  func generateRefreshToken(code: String, appId: String) -> EventLoopFuture<AppleTokenResponse>
}

public struct LiveSIWAClient: SIWAClient {
  //https://appleid.apple.com/.well-known/openid-configuration

  let signers: JWTSigners
  let client: Client
  let logger: Logger

  public init(signers: JWTSigners, client: Client, logger: Logger) {
    self.signers = signers
    self.client = client
    self.logger = logger
  }
  
  public init(application: Application) {
    self.signers = application.jwt.signers
    self.client = application.client
    self.logger = application.logger
  }
  
  public init(request: Request) {
    self.signers = request.application.jwt.signers
    self.client = request.client
    self.logger = request.logger
  }
  
  public func `for`(_ request: Request) -> SIWAClient {
    Self.init(request: request)
  }
  
  var eventLoop: EventLoop {
    client.eventLoop
  }

  func clientSecret(appId: String) -> EventLoopFuture<String> {
    do {
      let payload = SIWAClientSecret(clientId: appId,
                                     teamId: try EnvVars.appleTeamId.load())
      let string = try signers.sign(payload, kid: .appleServicesKey)
      return eventLoop.makeSucceededFuture(string)
    } catch {
      logger.critical("Cannot sign request to Apple: \(error.localizedDescription)")
      return eventLoop.makeFailedFuture(error)
    }
  }
  
  public func validateRefreshToken(token: String, appId: String) -> EventLoopFuture<AppleResponse<AppleTokenRefreshResponse>> {
    self.clientSecret(appId: appId)
      .flatMap { clientSecret in
        let body = AppleAuthTokenBody(client_id: appId,
                                      client_secret: clientSecret,
                                      code: nil,
                                      grant_type: "refresh_token",
                                      refresh_token: token,
                                      redirect_uri: nil)
        
        return self.authToken(body: body)
      }
  }

  public func generateRefreshToken(code: String, appId: String) -> EventLoopFuture<AppleTokenResponse> {
    self.clientSecret(appId: appId)
      .flatMap { clientSecret in
        let body = AppleAuthTokenBody(client_id: appId,
                                      client_secret: clientSecret,
                                      code: code,
                                      grant_type: "authorization_code",
                                      refresh_token: nil,
                                      redirect_uri: nil)
        
        return self.authToken(body: body)
          .flatMap { (result: AppleResponse<AppleTokenResponse>) in
            switch result {
            case let .decoded(token):
              return self.eventLoop.makeSucceededFuture(token)
            case let .error(appleError):
              return self.eventLoop.makeFailedFuture(appleError)
            }
          }
      }
  }
}

private extension LiveSIWAClient {
  // https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user
  // https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
  
  func authToken<D: Decodable>(body: AppleAuthTokenBody) -> EventLoopFuture<AppleResponse<D>> {
    self.buildRequest(body)
      .flatMap(self.sendRequest)
      .flatMap(self.interpretResponse)
  }
  
  private func sendRequest(_ clientRequest: ClientRequest) -> EventLoopFuture<ClientResponse> {
    self.client.send(clientRequest)
  }
  
  private func interpretResponse<D: Decodable>(_ clientResponse: ClientResponse) -> EventLoopFuture<AppleResponse<D>> {
    do {
      if clientResponse.status == .ok {
        let decoded = try clientResponse.content.decode(D.self)
        return self.eventLoop.makeSucceededFuture(.decoded(decoded))
      } else {
        let appleError = try clientResponse.content.decode(AppleErrorResponse.self)
        return self.eventLoop.makeSucceededFuture(.error(appleError))
      }
    } catch {
      return self.eventLoop.makeFailedFuture(error)
    }
  }
  
  private func buildRequest(_ body: AppleAuthTokenBody) -> EventLoopFuture<ClientRequest> {
    do {
      let uri = URI(scheme: "https", host: "appleid.apple.com", path: "/auth/token")
      var clientRequest = ClientRequest(method: .POST, url: uri)
      try clientRequest.content.encode(body, as: .urlEncodedForm)
      return self.eventLoop.makeSucceededFuture(clientRequest)
    } catch {
      return self.eventLoop.makeFailedFuture(error)
    }
  }
}
