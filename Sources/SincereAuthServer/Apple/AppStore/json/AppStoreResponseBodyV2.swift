import Vapor
import JWT

struct AppStoreResponseBodyV2: Content {
  let signedPayload: String
  
  struct SignedPayload: RawRepresentable {
    let rawValue: String
    let header: String
    let payload: String
    let signature: String
    
    init?(rawValue: String) {
      
      let splits = rawValue.split(separator: ".")
      guard splits.count == 3 else {
        return nil
      }
      
      self.header = String(splits[0])
      self.payload = String(splits[1])
      self.signature = String(splits[2])
      self.rawValue = rawValue
    }
  }
}


