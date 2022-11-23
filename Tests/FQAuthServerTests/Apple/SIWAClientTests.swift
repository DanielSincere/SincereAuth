//
//  SIWAClientTests.swift
//  
//
//  Created by Daniel on 11/19/22.
//

import XCTest
import Vapor
@testable import FQAuthServer

final class SIWAClientTests: XCTestCase {
  
  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  func testExample() throws {
    
    let stubbedResponse = ClientResponse(status: .ok, body: )
    let httpClient = FakeClient(stubbedResponse: stubbedResponse, eventLoop: app.eventLoopGroup.next())
    let siwaClient = SIWAClient(signers: app.jwt.signers,
                                client: httpClient,
                                eventLoop: app.eventLoopGroup.next(),
                                logger: app.logger)
    
    let response = try siwaClient.generateRefreshToken(code: "code123").wait()
    
    let request: ClientRequest = try XCTUnwrap(httpClient.receivedRequest)
    XCTAssertEqual(request.url.string, "asd.comf")
  }
  
  
  class FakeClient: Client {
    var receivedRequest: ClientRequest?
    
    let stubbedResponse: ClientResponse
    var eventLoop: NIOCore.EventLoop
    init(stubbedResponse: ClientResponse = ClientResponse(status: .ok), eventLoop: NIOCore.EventLoop) {
      self.stubbedResponse = stubbedResponse
      self.eventLoop = eventLoop
    }
    
    func delegating(to eventLoop: NIOCore.EventLoop) -> Vapor.Client {
      self.eventLoop = eventLoop
      return self
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
      self.receivedRequest = request
      return eventLoop.makeSucceededFuture(stubbedResponse)
    }
  }
}
