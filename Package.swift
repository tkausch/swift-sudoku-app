// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SudokuApp",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "SudokuAppUI", targets: ["SudokuAppUI"]),
        .executable(name: "SudokuApp", targets: ["SudokuApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tkausch/swift-sudoku-solver.git", from: "2.1.0"),
    ],
    targets: [
        // `SudokuSession` and the app screens around SudokuKit's SudokuBoardView and SudokuNumberPad.
        .target(
            name: "SudokuAppUI",
            dependencies: [
                .product(name: "SudokuKit", package: "swift-sudoku-solver"),
                .product(name: "SudokuUI", package: "swift-sudoku-solver"),
            ]
        ),
        // macOS app: `swift run SudokuApp`. macOS only; the iOS app is iOS/Sudoku.xcodeproj.
        .executableTarget(name: "SudokuApp", dependencies: ["SudokuAppUI"]),
        .testTarget(
            name: "SudokuAppUITests",
            dependencies: ["SudokuAppUI", .product(name: "SudokuKit", package: "swift-sudoku-solver")]
        ),
    ]
)
