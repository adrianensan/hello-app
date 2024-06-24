// swift-tools-version: 6.0
import PackageDescription

var dependencies: [Package.Dependency] = []
var additionalTargets: [Target] = []
#if os(iOS) || os(macOS)
let opensslPackage: Package.Dependency
dependencies.append(.package(url: "https://github.com/adrianensan/openssl", branch: "main"))
let opensslTargetDependency: Target.Dependency = .product(name: "OpenSSL", package: "openssl")
#else
additionalTargets.append(.systemLibrary(name: "OpenSSL",
                                        path: "server/openssl",
                                        pkgConfig: "openssl",
                                        providers: [.apt(["openssl libssl-dev"])]))
let opensslTargetDependency: Target.Dependency = .target(name: "OpenSSL")
#endif

let package = Package(
  name: "HelloApp",
  platforms: [.iOS(.v18), .macOS(.v15), .watchOS(.v11), .visionOS(.v2)],
  products: [
    .library(name: "HelloApp", targets: ["HelloApp"]),
    .library(name: "HelloCore", targets: ["HelloCore"]),
    .library(name: "HelloServer", targets: ["HelloServer"]),
    .library(name: "HelloAppIconGenerator", targets: ["HelloAppIconGenerator"]),
  ],
  dependencies: dependencies,
  targets: additionalTargets + [
    .target(name: "HelloCore",
            dependencies: [],
            path: "core"),
    .target(name: "HelloApp",
            dependencies: ["HelloCore"],
            path: "app"),
    .target(name: "HelloServer",
            dependencies: ["HelloCore", opensslTargetDependency],
            path: "server/code"),
    .target(name: "HelloAppIconGenerator",
            dependencies: ["HelloApp"],
            path: "app-icon-generator"),
    .testTarget(name: "HelloAppTests",
                dependencies: ["HelloApp"],
                path: "Tests")
    
  ]
)
