import AppKit
import SwiftUI
import SudokuAppUI

/// The macOS app: `swift run SudokuApp`. The iOS app lives in `iOS/Sudoku`.
@main
struct SudokuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("Sudoku") {
            SudokuRootView()
                .frame(minWidth: 420, minHeight: 640)
        }
        .defaultSize(width: 520, height: 760)
    }
}

/// A SwiftPM executable has no app bundle, so macOS starts it as a background
/// process. Make it a regular app with a Dock icon and a window in front.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
