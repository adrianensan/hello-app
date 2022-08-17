// swift-tools-version: 5.7
import PackageDescription

let useLocal = false // ProcessInfo.process.environment["USE_LOCAL_HELLO"] != nil

let helloCorePackage: Package.Dependency
if useLocal {
  helloCorePackage = .package(name: "hello-core", path: "../hello-core")
} else {
  helloCorePackage = .package(url: "https://github.com/adrianensan/hello-core", branch: "main")
}

//#if os(iOS)
//let excludedUIPaths = ["macOS/"]
//#elseif os(macOS)
//let excludedUIPaths = ["iOS/"]
//#elseif os(Linux)
//let excludedUIPaths = ["iOS/", "macOS/"]
//#endif


let package = Package(
  name: "HelloApp",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(name: "HelloApp", targets: ["HelloApp"])
  ],
  dependencies: [helloCorePackage],
  targets: [
    .target(name: "HelloApp",
            dependencies: [.product(name: "HelloCore", package: "hello-core")],
            path: "code")
  ]
)
