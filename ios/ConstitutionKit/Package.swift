// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConstitutionKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ConstitutionKit", targets: ["ConstitutionKit"]),
    ],
    targets: [
        .target(name: "ConstitutionKit"),
        .testTarget(name: "ConstitutionKitTests", dependencies: ["ConstitutionKit"]),
    ]
)
