import SwiftUI
import SudokuKit
import SudokuUI

/// SudokuKit's board and number pad (with Erase, Undo and Hint), and a title and clock.
struct SudokuSessionView: View {
    let session: SudokuSession
    let startNewGame: () -> Void

    @State private var selection: SudokuCell?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(session.title).font(.headline)
                Spacer()
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(formatTime(session.elapsed(at: context.date))).monospacedDigit()
                }
            }
            .font(.subheadline)

            SudokuBoardView(game: session.game, selection: $selection)
                .overlay {
                    if session.status == .won { winBanner }
                }

            SudokuNumberPad(game: Binding(get: { session.game }, set: { session.apply($0) }),
                            selection: selection)
                .disabled(session.isFinished)
        }
        .padding()
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: session.isFinished) { if session.isFinished { selection = nil } }
        .animation(.easeOut(duration: 0.15), value: session.status)
    }

    private var winBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("Solved!").font(.title.bold())
            Text("Time: \(formatTime(session.elapsed()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("New Game", action: startNewGame)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 12)
        .transition(.scale.combined(with: .opacity))
    }
}

/// `m:ss`, or `h:mm:ss` from one hour on.
func formatTime(_ interval: TimeInterval) -> String {
    let seconds = Int(interval)
    let h = seconds / 3600, m = seconds / 60 % 60, s = seconds % 60
    return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
}
