// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PinkGoatApp",
    dependencies: [
        .package(url: "https://github.com/vapor/http.git", from: "3.0.0"),
    ],
    targets: [
      .target(name: "PinkGoatApp", dependencies: ["HTTP"], path: "PinkGoatApp")      
    ]
)