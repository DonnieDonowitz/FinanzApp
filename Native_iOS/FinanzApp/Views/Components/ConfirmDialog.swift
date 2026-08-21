import SwiftUI

struct ConfirmDialog: View {
    let title: String
    let message: String
    let confirmLabel: String
    let cancelLabel: String
    let isDestructive: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var animate = false

    init(
        title: String,
        message: String,
        confirmLabel: String = "Elimina",
        cancelLabel: String = "Annulla",
        isDestructive: Bool = true,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmLabel = confirmLabel
        self.cancelLabel = cancelLabel
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            AppColors.overlay
                .ignoresSafeArea()
                .opacity(animate ? 1 : 0)

            GlassView(intensity: .strong, radius: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.expense)
                        .padding(.top, 8)

                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.text)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.easeOut) { animate = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onCancel() }
                        }) {
                            Text(cancelLabel)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.glass)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

                        Button(action: {
                            withAnimation(.easeOut) { animate = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onConfirm() }
                        }) {
                            Text(confirmLabel)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isDestructive ? AppColors.expense : AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }
                .padding(24)
            }
            .padding(.horizontal, 40)
            .scaleEffect(animate ? 1 : 0.85)
            .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                animate = true
            }
        }
    }
}