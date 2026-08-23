import SwiftUI

/// Editor for the single general monthly spending budget. Presented as a sheet both from the
/// Home dashboard's budget card and from Settings, so the two stay in sync automatically
/// (they both just call `vm.setMonthlyBudget`).
struct BudgetEditSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""

    private var parsedAmount: Double? {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value >= 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient()
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L.monthlyBudget).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.textTertiary).tracking(0.5)
                        GlassView(intensity: .strong, radius: 22) {
                            HStack(spacing: 4) {
                                Text(AppSettingsStore.currentCurrencySymbol)
                                    .font(.system(size: 26, weight: .light))
                                    .foregroundStyle(AppColors.textTertiary)
                                TextField("0", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundStyle(AppColors.text)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 16).padding(.horizontal, 20)
                        }
                    }

                    Text(L.budgetExplanation)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)

                    Button {
                        guard let value = parsedAmount else { return }
                        vm.setMonthlyBudget(value)
                        dismiss()
                    } label: {
                        Text(L.save)
                            .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(parsedAmount != nil ? AppColors.primary : AppColors.textTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(parsedAmount == nil)

                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 20)
            }
            .navigationTitle(L.monthlyBudget)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.cancel) { dismiss() }.foregroundStyle(AppColors.textSecondary)
                }
            }
            .onAppear {
                amount = vm.monthlyBudget > 0 ? String(format: "%.2f", vm.monthlyBudget) : ""
            }
        }
    }
}
