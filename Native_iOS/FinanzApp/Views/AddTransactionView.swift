import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var type = "expense"
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var showCategoryPicker = false
    @State private var isSaving = false

    let initialType: String?
    let editTransaction: Transaction?

    init(initialType: String? = nil, editTransaction: Transaction? = nil) {
        self.initialType = initialType
        self.editTransaction = editTransaction
        if let t = editTransaction {
            _type = State(initialValue: t.type)
            _amount = State(initialValue: String(format: "%.2f", t.amount))
            _description = State(initialValue: t.description)
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            f.locale = Locale(identifier: "en_US_POSIX")
            _date = State(initialValue: f.date(from: t.date) ?? Date())
        } else if let t = initialType {
            // Setting this in `.onAppear` instead of here was unreliable: this view is
            // presented via two separate `.sheet` modifiers on the same parent (add vs.
            // edit), and `.onAppear` firing after the first render could lose the race
            // against the initial "expense" default. Setting it at init time is deterministic.
            _type = State(initialValue: t)
        }
    }

    private let quickAmounts = [10.0, 20.0, 50.0, 100.0, 200.0]

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient()
                ScrollView {
                    VStack(spacing: 16) {
                        // Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.amount)
                                .font(.system(size: 12, weight: .bold))
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

                        // Quick amounts
                        HStack(spacing: 8) {
                            ForEach(quickAmounts, id: \.self) { q in
                                Button {
                                    amount = String(format: "%.0f", q)
                                } label: {
                                    Text("\(AppSettingsStore.currentCurrencySymbol)\(Int(q))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(AppColors.glass)
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        // Type
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.type).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.5)
                            HStack(spacing: 8) {
                                TypeChip(L.expense, icon: "arrow.up", active: type == "expense", tint: AppColors.expense) { type = "expense"; selectedCategory = nil }
                                TypeChip(L.income, icon: "arrow.down", active: type == "income", tint: AppColors.income) { type = "income"; selectedCategory = nil }
                            }
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.description).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.5)
                            GlassView(intensity: .strong, radius: 18) {
                                TextField(L.descriptionPlaceholder, text: $description)
                                    .font(.system(size: 16)).foregroundStyle(AppColors.text).padding(16)
                            }
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.categoryLabel).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.5)
                            Button { showCategoryPicker = true } label: {
                                GlassView(intensity: .strong, radius: 18) {
                                    HStack {
                                        if let cat = selectedCategory {
                                            ZStack {
                                                Circle().fill(cat.displayColor.opacity(0.22)).frame(width: 30, height: 30)
                                                CategoryIconView(icon: resolvedIcon(for: cat), size: 13)
                                                    .foregroundStyle(cat.displayColor)
                                            }
                                            Text(L.categoryName(cat.name)).font(.system(size: 16)).foregroundStyle(AppColors.text)
                                        } else {
                                            Text(L.selectCategory).font(.system(size: 16)).foregroundStyle(AppColors.textTertiary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textTertiary)
                                    }
                                    .padding(16)
                                }
                            }
                        }

                        // Date
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L.date).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.5)
                            GlassView(intensity: .strong, radius: 18) {
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .labelsHidden().tint(AppColors.primary).padding(8)
                            }
                        }

                        // Submit
                        Button {
                            guard !isSaving,
                                  let amt = Double(amount.replacingOccurrences(of: ",", with: ".")),
                                  amt > 0, let cat = selectedCategory else { return }
                            isSaving = true
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            if let existing = editTransaction {
                                var updated = existing
                                updated.type = type
                                updated.amount = amt
                                updated.description = description
                                updated.categoryId = cat.id
                                updated.date = f.string(from: date)
                                vm.updateTransaction(updated)
                            } else {
                                vm.addTransaction(type: type, amount: amt, description: description, categoryId: cat.id, categoryName: cat.name, date: f.string(from: date))
                            }
                            dismiss()
                        } label: {
                            Text(L.save)
                                .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(canSubmit ? AppColors.primary : AppColors.textTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .disabled(!canSubmit || isSaving)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16).padding(.top, 12)
                }
            }
            .navigationTitle(editTransaction != nil ? L.editMovement : L.newMovement)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.cancel) { dismiss() }.foregroundStyle(AppColors.textSecondary)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPicker(selectedCategory: $selectedCategory, type: type).environmentObject(vm)
            }
            .onAppear {
                if let t = editTransaction {
                    selectedCategory = vm.categoryById(t.categoryId)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !amount.isEmpty && !description.isEmpty && selectedCategory != nil
    }
}

struct TypeChip: View {
    let label: String; let icon: String; let active: Bool; let tint: Color; let action: () -> Void
    init(_ label: String, icon: String, active: Bool, tint: Color, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.active = active; self.tint = tint; self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .bold))
                Text(label).font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(active ? .white : AppColors.textTertiary)
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(active ? tint : AppColors.glass)
            .clipShape(Capsule())
        }
    }
}