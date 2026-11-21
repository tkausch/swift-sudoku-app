import Testing
import SudokuKit
@testable import SudokuAppUI

@MainActor
private func makeSession() throws -> SudokuSession {
    SudokuSession(game: SudokuGame(puzzle: try SudokuParser.parse(SudokuPuzzle.all[0].cells)), title: "Test")
}

/// (0, 2) is empty in the Wikipedia puzzle.
private let empty = (row: 0, col: 2)

extension SudokuSession {
    /// Changes a copy of the game and applies it, as `SudokuNumberPad` does.
    func edit(_ change: (inout SudokuGame) -> Void) {
        var newGame = game
        change(&newGame)
        apply(newGame)
    }
}

@Suite("SudokuSession")
@MainActor
struct SudokuSessionTests {
    @Test func appliedChangesAreTakenOver() throws {
        let session = try makeSession()
        session.edit { $0.set(4, atRow: empty.row, col: empty.col) }
        #expect(session.game.board[empty.row, empty.col] == 4)
        session.edit { $0.undo() }
        #expect(session.game == SudokuGame(puzzle: session.game.puzzle))
    }

    @Test func gamesForOtherPuzzlesAreIgnored() throws {
        let session = try makeSession()
        let before = session.game
        session.apply(SudokuGame(puzzle: try SudokuParser.parse(SudokuPuzzle.all[1].cells)))
        #expect(session.game == before)
    }

    @Test func solvingWinsTheGame() throws {
        let session = try makeSession()
        session.edit { game in
            for row in 0..<Sudoku.size {
                for col in 0..<Sudoku.size { _ = game.set(game.hint(forRow: row, col: col), atRow: row, col: col) }
            }
        }
        #expect(session.status == .won)
        #expect(session.isFinished)
    }

    @Test func changesAreIgnoredAfterTheGameEnds() throws {
        let session = try makeSession()
        session.revealSolution()
        #expect(session.status == .revealed)
        session.edit { $0.undo() }
        #expect(session.game.isSolved)
    }

    @Test func restartGoesBackToTheGivens() throws {
        let session = try makeSession()
        session.edit { $0.set(4, atRow: empty.row, col: empty.col) }
        session.revealSolution()
        session.restart()
        #expect(session.status == .playing)
        #expect(session.game == SudokuGame(puzzle: session.game.puzzle))
    }

    @Test func pausedClockStandsStill() throws {
        let session = try makeSession()
        session.pause()
        let t = session.elapsed()
        #expect(session.elapsed(at: .now.addingTimeInterval(100)) == t)
    }

    @Test(arguments: SudokuDifficulty.allCases)
    func generatesSolvablePuzzles(_ difficulty: SudokuDifficulty) async {
        let session = await SudokuSession.generate(difficulty)
        #expect(session.title == difficulty.title)
        #expect(DFSSolver().countSolutions(session.game.puzzle) == 1)
    }

    @Test func loadsEveryWellKnownPuzzle() async throws {
        for puzzle in SudokuPuzzle.all {
            let session = try await SudokuSession.load(puzzle)
            #expect(session.title == puzzle.name)
        }
    }
}
