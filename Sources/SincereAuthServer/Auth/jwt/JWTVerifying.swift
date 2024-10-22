import JWTKit

protocol JWTVerifying {
  func verify<Payload>(
      _ token: String,
      as payload: Payload.Type
  ) throws -> Payload
      where Payload: JWTPayload
}

extension JWTSigners: JWTVerifying { }
