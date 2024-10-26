@testable import SincereAuthServer

extension AppleTokenResponse {

  static let meaninglessStub: Self = .init(access_token: "access_token",
                                       expires_in: 3600,
                                       id_token: "id_token",
                                       refresh_token: "refresh_token",
                                       token_type: "bearer")
}
