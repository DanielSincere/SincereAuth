import Vapor
import JWT
import Foundation

struct AppStoreResponseBodyV2: Content {
  let signedPayload: SignedPayload
  
  struct SignedPayload: Codable {
    let header: String
    let payload: String
    let signature: String
    let rawValue: String
    
    init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      let splits = rawValue.split(separator: ".")
      guard splits.count == 3 else {
        throw IncorrectNumberOfPeriodsError()
      }
      self.rawValue = rawValue
      
      self.header = String(data: Data(base64Encoded: String(splits[0]))!, encoding: .utf8)!
      self.payload = String(data: Data(base64Encoded: String(splits[1]))!, encoding: .utf8)!
      self.signature = String(data: Data(base64Encoded: String(splits[2]))!, encoding: .utf8)!
    }
    
    func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(self.rawValue)
    }
    
    struct IncorrectNumberOfPeriodsError: LocalizedError {
      var errorDescription: String? = "Expected three fields delimited by two periods."
    }
  }
}
