// swift-tools-version: 6.0
import PackageDescription

var dependencies: [Package.Dependency] = []
var additionalTargets: [Target] = []
#if os(Linux)
additionalTargets.append(.systemLibrary(name: "OpenSSL",
                                        path: "server/openssl",
                                        pkgConfig: "openssl",
                                        providers: [.apt(["openssl libssl-dev"])]))
let opensslTargetDependency: Target.Dependency = .target(name: "OpenSSL")
#else
let opensslPackage: Package.Dependency
dependencies.append(.package(url: "https://github.com/adrianensan/openssl", branch: "main"))
let opensslTargetDependency: Target.Dependency = .product(name: "OpenSSL", package: "openssl")
#endif

let package = Package(
  name: "HelloApp",
  platforms: [.iOS(.v18), .macOS(.v15), .watchOS(.v11), .visionOS(.v2)],
  products: [
    .library(name: "HelloApp", targets: ["HelloApp"]),
    .library(name: "HelloAppMain", targets: ["HelloAppMain"]),
    .library(name: "HelloCore", targets: ["HelloCore"]),
    .library(name: "HelloServer", targets: ["HelloServer"]),
    .library(name: "HelloAppIconGenerator", targets: ["HelloAppIconGenerator"]),
  ],
  dependencies: dependencies,
  targets: additionalTargets + [
    .target(name: "HelloCore", path: "core"),
    .target(name: "HelloApp", dependencies: ["HelloCore"], path: "app"),
    .target(name: "HelloAppMain", dependencies: ["HelloApp"], path: "app-main", resources: [.process("resources")]),
    .target(name: "HelloServer", dependencies: ["HelloCore", opensslTargetDependency], path: "server/code"),
    .target(name: "HelloAppIconGenerator",
            dependencies: ["HelloApp"],
            path: "app-icon-generator",
            resources: [.process("resources")]),
    .testTarget(name: "HelloAppTests", dependencies: ["HelloApp"], path: "Tests")
    
  ],
  swiftLanguageModes: [.v6]
)
