import SwiftUI

struct QuickAddBar: View {
    let onIncome: () -> Void
    let onExpense: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onExpense) {
                Label {
                    Text(L.newExpense)
                        .font(.system(size: 14, weight: .bold))
                } icon: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.expense)
                .clipShape(Capsule())
            }

            Button(action: onIncome) {
                Label {
                    Text(L.newIncome)
                        .font(.system(size: 14, weight: .bold))
                } icon: {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.income)
                .clipShape(Capsule())
            }
        }
    }
}