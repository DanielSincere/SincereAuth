import Vapor
import QueuesRedisDriver

extension Application {

  func configureMigrations() throws {

      self.migrations.add(CreateFunctionMigration(),
                          CreateUserMigration(),
                          CreateSiwaMigration(),
                          CreateRefreshTokenMigration(),
                          AddRolesToUserMigration(),
                          AddAppIdToSiwaMigration(),
                          to: .psql)
    
    if Environment.get("RUN_AUTO_MIGRATE") == "YES" {
      try self.autoMigrate().wait()
    }
  }
}
