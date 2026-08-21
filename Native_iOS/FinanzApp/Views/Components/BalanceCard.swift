import SwiftUI

struct BalanceCard: View {
    let income: Double
    let expense: Double
    let balance: Double
    let monthName: String

    var body: some View {
        GlassView {
            VStack(alignment: .leading, spacing: 0) {
                Text(L.totalBalance)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)

                // Amount: "€ 4.286", sup style for decimals
                HStack(alignment: .top, spacing: 2) {
                    Text(amountInt)
                        .font(.system(size: 38, weight: .semibold, design: .monospaced))
                        .foregroundStyle(balance >= 0 ? AppColors.income : AppColors.expense)
                        .tracking(-0.3)
                    Text(",\(amountDec)")
                        .font(.system(size: 19, weight: .semibold, design: .monospaced))
                        .foregroundStyle((balance >= 0 ? AppColors.income : AppColors.expense).opacity(0.7))
                        .padding(.top, 6)
                }
                .padding(.top, 8)
                .lineSpacing(4)

                // Flow chips
                HStack(spacing: 12) {
                    FlowChip(label: L.incomes, amount: income, color: AppColors.income)
                    FlowChip(label: L.expenses, amount: expense, color: AppColors.expense)
                }
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 22, leading: 22, bottom: 20, trailing: 22))
        }
    }

    private var amountInt: String {
        let absBal = abs(balance)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
        formatter.maximumFractionDigits = 0
        let sign = balance < 0 ? "− " : ""
        return "\(sign)\(AppSettingsStore.currentCurrencySymbol) \(formatter.string(from: NSNumber(value: absBal)) ?? "0")"
    }

    private var amountDec: String {
        let absBal = abs(balance)
        let intPart = Int(absBal)
        let dec = Int(round((absBal - Double(intPart)) * 100))
        return String(format: "%02d", dec)
    }

}

struct FlowChip: View {
    let label: String
    let amount: Double
    let color: Color

    private var flowAmount: String {
        let sign = label == L.incomes ? "+ " : "− "
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: AppSettingsStore.currentLanguage.localeIdentifier)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let intStr = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return "\(sign)\(AppSettingsStore.currentCurrencySymbol)\(intStr)"
    }

    var body: some View {
        GlassView(radius: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .shadow(color: color.opacity(0.6), radius: 5)
                    Text(label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Text(flowAmount)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }
}
