import SwiftUI

/// A tasteful, minimal level-up celebration shown over whichever tab is active — mounted at
/// the app root (`ContentView`) rather than on `HomeView` so it appears regardless of where
/// the transaction that triggered it was added from.
struct LevelUpOverlay: View {
    let level: Int
    let onDismiss: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.45 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            GlassView(intensity: .strong, radius: 30) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle().fill(AppColors.primary.opacity(0.25)).frame(width: 84, height: 84)
                        Text("\(level)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primary)
                    }
                    Text(L.levelUpTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.text)
                    Text(L.levelUpBody(level: level))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                    Button(action: dismiss) {
                        Text(L.close)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
            .padding(.horizontal, 40)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appeared = true }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onDismiss() }
    }
}
