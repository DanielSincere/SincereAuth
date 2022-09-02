import FluentPostgresDriver

final class CreateMetaMigration: PostgresMigration {

  func prepare(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(
      #"CREATE EXTENSION "uuid-ossp";"#,

      #"""
      CREATE FUNCTION updated_at_timestamp()
      RETURNS TRIGGER AS $$
      BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """#
    )
  }

  func revert(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(
      #"DROP EXTENSION "uuid-ossp""#,
      #"DROP FUNCTION updated_at_timestamp"#
    )
  }
}
