import FluentPostgresDriver

final class AddAppIdToSiwaMigration: PostgresScriptMigration {
  let up = [
    #"ALTER TABLE "siwa" ADD COLUMN app_id TEXT NOT NULL,"#
  ]
  
  let down = [
    #"ALTER TABLE "siwa" DROP COLUMN app_id"#
  ]
}
