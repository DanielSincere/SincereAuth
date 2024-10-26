import XCTest
import Vapor
@testable import SincereAuthServer

final class AppStoreJsonCodableTests: XCTestCase {
  
  func testSignedPayload() throws {
    let fixture = """
    {
      "signedPayload": "YXNkZg==.MTIzNA==.MDAwMA=="
    }
    """.data(using: .utf8)!
    
    let decoded = try JSONDecoder().decode(AppStoreResponseBodyV2.self, from: fixture)
    XCTAssertEqual(decoded.signedPayload.header, "asdf")
    XCTAssertEqual(decoded.signedPayload.payload, "1234")
    XCTAssertEqual(decoded.signedPayload.signature, "0000")
  }
}
