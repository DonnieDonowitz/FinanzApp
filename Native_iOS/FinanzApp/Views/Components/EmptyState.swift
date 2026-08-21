import SwiftUI

struct EmptyState: View {
    let icon: String
    let message: String
    let submessage: String?

    init(icon: String, message: String, submessage: String? = nil) {
        self.icon = icon
        self.message = message
        self.submessage = submessage
    }

    var body: some View {
        GlassView(radius: 28) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 36))

                Text(message)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                if let sub = submessage {
                    Text(sub)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
        }
    }
}