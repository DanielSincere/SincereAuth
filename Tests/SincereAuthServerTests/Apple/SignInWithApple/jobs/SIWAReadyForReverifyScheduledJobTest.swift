import Foundation
@testable import SincereAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class SIWAReadyForReverifyScheduledJobTest: XCTestCase {

  var app: Application!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testDoesNothingWhenTheresNoAccounts() async throws {
    try await SIWAReadyForReverifyScheduledJob.enqueueJobs(
      logger: Logger(label: "test logger"),
      db: app.db(.psql),
      queue: app.queues.queue)


    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testDoesNothingWhenTheresNoAccountsThatNeedRefreshing() async throws {


    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")
    try await SIWAReadyForReverifyScheduledJob.enqueueJobs(
      logger: Logger(label: "test logger"),
      db: app.db(.psql),
      queue: app.queues.queue)


    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testEnqueusJobsForAccountsThatNeedRefreshing() async throws {

    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")

    let siwa1 = try XCTUnwrap(SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949", db: app.db(.psql)).wait())
    siwa1.attemptedRefreshResult = .failure
    try siwa1.save(on: app.db(.psql)).wait()


    let userID2 = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1999")

    let siwa2 = try XCTUnwrap(SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1999", db: app.db(.psql)).wait())

    siwa2.attemptedRefreshResult = .success
    try siwa2.save(on: app.db(.psql)).wait()

    try await SIWAReadyForReverifyScheduledJob.enqueueJobs(
      logger: Logger(label: "test logger"),
      db: app.db(.psql),
      queue: app.queues.queue)

    let (name1, payload1) = try app.queues.queue
      .nextPayload(as: SIWAModel.IDValue.self)
    let (name2, payload2) = try app.queues.queue
      .nextPayload(as: SIWAModel.IDValue.self)


    XCTAssertEqual(Set([payload1, payload2]),
                   Set([try siwa1.requireID(), try siwa2.requireID()]))

    XCTAssertEqual(name1, "RefreshTokenJob")
    XCTAssertEqual(name2, "RefreshTokenJob")
  }
}
