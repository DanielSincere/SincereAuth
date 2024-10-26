import Foundation
import JWTKit

enum AppleIdentityTokenFixtures: String {

  case fakeSample = """
  {
    "iss": "com.apple",
    "sub": "1234",
    "aud": "com.fullqueuedeveloper.SampleApp",
    "iat": 1675970158,
    "exp": 1675971158
  }
  """

  var decoded: AppleIdentityToken {
    try! JSONDecoder().decode(AppleIdentityToken.self, from: rawValue.data(using: .utf8)!)
  }
}
