import SwiftUI

struct AppLogo: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(AppColors.primary)
                    .frame(width: 5, height: 18)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(AppColors.primary)
                    .frame(width: 5, height: 26)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(AppColors.primary)
                    .frame(width: 5, height: 14)
                Text("→")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColors.primary)
                    .padding(.leading, 2)
            }

            Text("FinanzApp")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.text)
                .tracking(-0.3)

            Text("Finanze semplici e trasparenti")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
        }
    }
}