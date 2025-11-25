// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "StatisticsCorePackage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "StatisticsCore",
            targets: ["StatisticsCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.6.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0"),
        .package(url: "https://github.com/layoutBox/PinLayout.git", from: "1.10.0")
    ],
    targets: [
        .target(
            name: "StatisticsCore",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "PinLayout", package: "PinLayout")
            ],
            path: "Sources/StatisticsCore" 
        )
    ]
)


