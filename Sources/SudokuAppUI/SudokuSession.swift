import Foundation
import Observation
import SudokuKit

/// A game being played: SudokuKit's ``SudokuKit/SudokuGame`` plus its status and a clock.
///
/// `SudokuGame` already holds the givens, the player's digits, undo and the solution.
/// Edit it through the session so it can tell when the game is over. Bind views that
/// change a `SudokuGame` themselves, such as `SudokuNumberPad`, through ``apply(_:)``:
/// `Binding(get: { session.game }, set: { session.apply($0) })`.
@MainActor
@Observable
public final class SudokuSession {
    public enum Status: Sendable {
        case playing, won, revealed
    }

    public let title: String
    public private(set) var game: SudokuGame
    public private(set) var status = Status.playing

    private var playedTime: TimeInterval = 0
    private var resumedAt: Date? = .now

    /// Starts a session. The puzzle must have a solution.
    public init(game: SudokuGame, title: String) {
        self.game = Self.withSolution(game)
        self.title = title
    }

    /// A new puzzle from `SudokuGenerator`, made and solved off the main thread.
    public static func generate(_ difficulty: SudokuDifficulty) async -> SudokuSession {
        let game = await Task.detached(priority: .userInitiated) {
            withSolution(SudokuGame(puzzle: SudokuGenerator().generate(difficulty)))
        }.value
        return SudokuSession(game: game, title: difficulty.title)
    }

    /// One of SudokuKit's well-known puzzles, solved off the main thread.
    public static func load(_ puzzle: SudokuPuzzle) async throws -> SudokuSession {
        let game = try await Task.detached(priority: .userInitiated) {
            withSolution(SudokuGame(puzzle: try SudokuParser.parse(puzzle.cells)))
        }.value
        return SudokuSession(game: game, title: puzzle.name)
    }

    /// Computes and stores `game.solution` now. Its getter is `mutating`, so the first
    /// read would otherwise write to the observed ``game`` in the middle of a move.
    nonisolated private static func withSolution(_ game: SudokuGame) -> SudokuGame {
        var game = game
        _ = game.solution
        return game
    }

    // MARK: - State

    public var isFinished: Bool { status != .playing }

    /// Play time, not counting time while paused.
    public func elapsed(at date: Date = .now) -> TimeInterval {
        playedTime + (resumedAt.map { date.timeIntervalSince($0) } ?? 0)
    }

    public func pause() {
        guard let resumedAt else { return }
        playedTime += Date.now.timeIntervalSince(resumedAt)
        self.resumedAt = nil
    }

    public func resume() {
        guard !isFinished, resumedAt == nil else { return }
        resumedAt = .now
    }

    // MARK: - Moves

    /// Takes over a changed copy of ``game``. Ignored once the game is over.
    public func apply(_ newGame: SudokuGame) {
        guard !isFinished, newGame.puzzle == game.puzzle else { return }
        game = newGame
        if game.isSolved { finish(.won) }
    }

    /// Clears every entry and restarts the clock.
    public func restart() {
        while game.undo() {}   // keeps the computed solution, unlike a new SudokuGame
        status = .playing
        playedTime = 0
        resumedAt = .now
    }

    /// Fills in the solution and ends the game.
    public func revealSolution() {
        guard !isFinished else { return }
        let solution = game.solution
        for row in 0..<Sudoku.size {
            for col in 0..<Sudoku.size {
                game.set(solution[row, col], atRow: row, col: col)   // givens are skipped
            }
        }
        finish(.revealed)
    }

    private func finish(_ status: Status) {
        self.status = status
        pause()
    }
}
