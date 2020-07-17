// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxAVFoundation",
	platforms: [.iOS(.v8), .watchOS(.v6), .tvOS(.v9), .macOS(.v10_10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "RxAVFoundation", targets: ["RxAVFoundation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMinor(from: "5.1.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
			name: "RxAVFoundation",
			dependencies: [
				.product(name: "RxSwift", package: "RxSwift"),
				.product(name: "RxCocoa", package: "RxSwift")
			]
		)
    ]
)
