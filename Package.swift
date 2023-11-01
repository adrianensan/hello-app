// swift-tools-version: 5.9
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
  platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
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
            path: "core",
            swiftSettings: [
              .enableUpcomingFeature("DisableOutwardActorInference"),
              .enableUpcomingFeature("ImportObjcForwardDeclarations"),
              .enableUpcomingFeature("BareSlashRegexLiterals"),
              .enableUpcomingFeature("ExistentialAny"),
              .enableUpcomingFeature("ForwardTrailingClosures"),
              .enableUpcomingFeature("ConciseMagicFile")
            ]),
    .target(name: "HelloApp",
            dependencies: ["HelloCore"],
            path: "app",
            swiftSettings: [
              .enableUpcomingFeature("DisableOutwardActorInference"),
              .enableUpcomingFeature("ImportObjcForwardDeclarations"),
              .enableUpcomingFeature("BareSlashRegexLiterals"),
              .enableUpcomingFeature("ExistentialAny"),
              .enableUpcomingFeature("ForwardTrailingClosures"),
              .enableUpcomingFeature("ConciseMagicFile")
            ]),
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
