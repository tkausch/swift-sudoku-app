import SwiftUI
import SudokuAppUI

/// The iOS app. The macOS app is the package's `SudokuApp` executable.
@main
struct SudokuApp: App {
    var body: some Scene {
        WindowGroup { SudokuRootView() }
    }
}
