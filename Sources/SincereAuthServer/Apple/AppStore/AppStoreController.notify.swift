import Vapor

extension AppStoreController {
  
  /// Handle App Store Server Notifications, v2
  /// See more at  https://developer.apple.com/documentation/appstoreservernotifications/app-store-server-notifications-v2
  func notify(req: Request) async throws -> HTTPStatus {
    let body = try req.content.decode(AppStoreResponseBodyV2.self)
    return .ok
  }
}
