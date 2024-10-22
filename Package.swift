// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "SincereAuth",
  platforms: [
      .macOS(.v13),
  ],
  products: [
    .executable(name: "SincereAuthServer", targets: ["SincereAuthServer"]),
  ],
  dependencies: [

    .package(url: "https://github.com/DanielSincere/SincereAuthMiddleware.git", from: "0.3.1"),

    .package(url: "https://github.com/vapor/vapor.git", from: "4.106.0"),
    .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),

    .package(url: "https://github.com/vapor/fluent.git", from: "4.3.1"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.3"),
    .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.3.0"),

    .package(url: "https://github.com/vapor/redis.git", from: "4.1.3"),
    .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
    .package(url: "https://github.com/DanielSincere/Sh.git", from: "1.0.2"),

    .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
  ],
  targets: [
    .executableTarget(name: "SincereAuthServer", dependencies: [
      .product(name: "Vapor", package: "vapor"),
      .product(name: "JWT", package: "jwt"),

      .product(name: "PostgresKit", package: "postgres-kit"),
      .product(name: "Fluent", package: "fluent"),
      .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),

      .product(name: "Redis", package: "redis"),
      .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),

      .product(name: "SincereAuthMiddleware", package: "SincereAuthMiddleware"),

      .product(name: "Leaf", package: "leaf"),

      "Sh",
    ],
    swiftSettings: [
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
    ]),
    .testTarget(name: "SincereAuthServerTests", dependencies: [
      .product(name: "XCTVapor", package: "vapor"),
      "SincereAuthServer",
    ]),
  ]
)
