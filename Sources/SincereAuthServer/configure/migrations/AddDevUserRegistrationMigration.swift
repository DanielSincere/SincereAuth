import FluentPostgresDriver

final class AddDevUserRegistrationMigration: PostgresScriptMigration {
  
  let up = [
    #"ALTER TYPE user_registration_method ADD VALUE 'dev'"#
  ]
  
  let down: [String] = [
//    #"ALTER TYPE user_registration_method DROP VALUE 'dev'"#
  ]
}
