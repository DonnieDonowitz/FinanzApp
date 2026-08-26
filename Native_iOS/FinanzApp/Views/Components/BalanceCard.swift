import SwiftUI

/// Three equal peer cards — income, expenses, balance — instead of one dominant "balance up
/// top" hero card. None of the three is visually privileged over the others.
struct BalanceCard: View {
    let income: Double
    let expense: Double
    let balance: Double

    var body: some View {
        HStack(spacing: 10) {
            FlowChip(label: L.incomes, amount: income, color: AppColors.income, forcePositiveSign: true)
            FlowChip(label: L.expenses, amount: expense, color: AppColors.expense, forcePositiveSign: false)
            FlowChip(label: L.balance, amount: balance, color: balance >= 0 ? AppColors.income : AppColors.expense)
        }
    }
}

struct FlowChip: View {
    let label: String
    let amount: Double
    let color: Color
    /// `nil` infers the sign from `amount`'s own value (used for balance, which can go either
    /// way); income/expense force it since their `amount` is always passed as a magnitude.
    var forcePositiveSign: Bool? = nil

    private var flowAmount: String {
        let isPositive = forcePositiveSign ?? (amount >= 0)
        let sign = isPositive ? "+ " : "− "
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let intStr = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return "\(sign)\(AppSettingsStore.currentCurrencySymbol)\(intStr)"
    }

    var body: some View {
        GlassView(radius: 18) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                    Text(label)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                Text(flowAmount)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 10))
        }
    }
}
