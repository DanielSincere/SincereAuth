import Vapor

final class AppStoreController: RouteCollection {
  func boot(routes: any Vapor.RoutesBuilder) throws {
    routes.group("app-store") { appStore in
      appStore.post("notify", use: notify(req:))
    }
  }
}
