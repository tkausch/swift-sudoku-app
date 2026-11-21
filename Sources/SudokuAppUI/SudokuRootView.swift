import SwiftUI
import SudokuKit

/// The whole app: put this in a `WindowGroup`. Starts with a medium puzzle.
public struct SudokuRootView: View {
    @State private var session: SudokuSession?
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if let session {
                    SudokuSessionView(session: session) { start { await SudokuSession.generate(.medium) } }
                        .id(ObjectIdentifier(session))   // new game, new selection
                } else {
                    ProgressView("Generating puzzle…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Sudoku")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbar }
        }
        .task {
            if session == nil { start { await SudokuSession.generate(.medium) } }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { session?.resume() } else { session?.pause() }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Section("New Puzzle") {
                    ForEach(SudokuDifficulty.allCases) { difficulty in
                        Button(difficulty.title) { start { await SudokuSession.generate(difficulty) } }
                    }
                }
                Section("Classic Puzzles") {
                    ForEach(SudokuPuzzle.all) { puzzle in
                        // Built-in puzzles always parse, so `try?` never drops one.
                        Button(puzzle.name) { start { try? await SudokuSession.load(puzzle) } }
                    }
                }
            } label: {
                Label("New Game", systemImage: "plus")
            }
        }
        ToolbarItem(placement: .secondaryAction) {
            Button("Restart", systemImage: "arrow.counterclockwise") { session?.restart() }
                .disabled(session == nil)
        }
        ToolbarItem(placement: .secondaryAction) {
            Button("Show Solution", systemImage: "checkmark.seal") { session?.revealSolution() }
                .disabled(session?.isFinished ?? true)
        }
    }

    private func start(_ makeSession: @escaping @MainActor () async -> SudokuSession?) {
        Task {
            if let newSession = await makeSession() { session = newSession }
        }
    }
}
