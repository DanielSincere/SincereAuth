import Vapor
import Redis

extension Application {
  func configureWebSessions() {
//    self.sessions.use(.redis)
    self.middleware.use(self.sessions.middleware)
    self.middleware.use(UserModel.sessionAuthenticator())
  
  }
}
