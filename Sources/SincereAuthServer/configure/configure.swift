import Vapor
import Leaf

extension Application {

  func configure() throws {
    try self.configurePostgres()
    try self.configureMigrations()
    try self.configureRedis()
    try self.configureQueues()
    self.configureWebSessions()
    try self.configureRoutes()

    try self.configureSigning()
    
    self.configureCommands()
    
    self.configureServices()

    self.views.use(.leaf)
  
  }
}
