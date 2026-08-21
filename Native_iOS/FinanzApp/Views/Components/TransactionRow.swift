import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(categoryColor.opacity(0.20))
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(categoryColor.opacity(0.35), lineWidth: 1)
                    )
                CategoryIconView(icon: resolvedIcon(for: category), size: 16)
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(AppColors.text)
                    .lineLimit(1)
                Text("\(timeAgo) · \(categoryName)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.leading, 4)

            Spacer(minLength: 8)

            Text(formattedAmount)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(transaction.isExpense ? AppColors.expenseLight : AppColors.incomeLight)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
    }

    private var category: Category? {
        vm.categoryById(transaction.categoryId)
    }

    private var categoryColor: Color {
        category?.displayColor ?? AppColors.textTertiary
    }

    private var categoryName: String {
        L.categoryName(category?.name ?? "")
    }

    private var timeAgo: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        guard let d = f.date(from: transaction.date) else { return transaction.date }
        let days = Calendar.current.dateComponents([.day], from: d, to: Date()).day ?? 0
        if days == 0 { return L.today }
        if days == 1 { return L.yesterday }
        return formatDateShort(transaction.date)
    }

    private var formattedAmount: String {
        "\(transaction.isExpense ? "−" : "+")\(formatCurrency(transaction.amount))"
    }
}
