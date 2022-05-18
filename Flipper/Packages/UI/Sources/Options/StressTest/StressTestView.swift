import Core
import SwiftUI

struct StressTestView: View {
    @StateObject var viewModel: StressTestViewModel

    var body: some View {
        VStack {
            HStack {
                Text("success: \(viewModel.successCount)")
                Text("error: \(viewModel.errorCount)")
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            List(viewModel.events.reversed()) {
                Text($0.message)
                    .foregroundColor($0.color)
            }

            HStack {
                Spacer()
                RoundedButton("Start", action: viewModel.start)
                Spacer()
                RoundedButton("Stop", action: viewModel.stop)
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Stress Test")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stop()
        }
    }
}

extension StressTest.Event {
    var color: Color {
        switch kind {
        case .info: return .primary
        case .debug: return .secondary
        case .success: return .sGreen
        case .error: return .sRed
        }
    }
}
