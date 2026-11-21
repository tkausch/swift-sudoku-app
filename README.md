# Swift Sudoku UI

A SwiftUI Sudoku game for macOS and iOS, built as a Swift package on top of
[SudokuKit](https://github.com/tkausch/swift-sudoku-solver) 2.1 (package `swift-sudoku-solver`).

## Features

- New puzzles in three difficulties, made by `SudokuGenerator` (each has exactly one solution)
- Eight well-known puzzles, from the Wikipedia example to AI Escargot
- SudokuKit's `SudokuBoardView` and `SudokuNumberPad`: conflicts in red, the selected
  cell's row, column, box and matching digits highlighted
- Hint, erase and undo from the number pad, restart, show solution and a timer

## Run

```sh
swift run SudokuApp     # macOS
swift test
```

You can also open `Package.swift` in Xcode and run the `SudokuApp` scheme.

## Structure

| Target | Contents |
|---|---|
| `SudokuAppUI` | `SudokuSession`, an observable wrapper around SudokuKit's `SudokuGame` (givens, entries, undo, solution) that adds the game's status (playing, won, revealed) and a timer; and the app screens around SudokuKit's `SudokuBoardView` and `SudokuNumberPad`. `SudokuRootView` is the entry point. |
| `SudokuApp` | macOS app executable. |
| `SudokuAppUITests` | Swift Testing tests for `SudokuSession`. |

Puzzles, difficulties, parsing, solving, generating, undo, hints, and the board and number
pad all come from SudokuKit. The number pad edits a `SudokuGame` directly, so it is bound
through `SudokuSession.apply(_:)`, which notices when the puzzle is solved.

### iOS

Open `iOS/Sudoku.xcodeproj`, choose the **Sudoku** scheme and an iPhone, and run.

Don't run the package's `SudokuApp` scheme on an iPhone: SwiftPM builds it as a bare
executable without an app bundle, and UIKit stops it at launch ("missing bundleID for
main bundle"). The iOS project wraps the `SudokuAppUI` library in a real app.

The project is generated from `iOS/project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen):
run `cd iOS && xcodegen` after changing it. Set your own bundle ID prefix there, and
pick your team in Xcode's Signing settings to run on a device.
