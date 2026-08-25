import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var vm: AppViewModel
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 20
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    @State private var showCategoryManager = false
    @State private var showBudgetEdit = false

    @State private var showBackupImporter = false
    @State private var showBackupExport = false
    @State private var showBackupFolderPicker = false
    @State private var backupDocument = TextFileDocument(text: "")
    @State private var showRestoreConfirm = false
    @State private var pendingRestoreJSON: String?
    @State private var backupResultMessage = ""
    @State private var showBackupResult = false

    @State private var showReminderDeniedAlert = false
    @State private var showExpenseAlertDeniedAlert = false
    @State private var newThresholdText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header
                budgetSection
                appearanceSection
                regionSection
                reminderSection
                expenseAlertSection
                managementSection
                backupSection
                autoBackupSection
                infoSection
                Spacer(minLength: 110)
            }
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showCategoryManager) {
            CategoryManagerView().environmentObject(vm)
        }
        .sheet(isPresented: $showBudgetEdit) {
            BudgetEditSheet().environmentObject(vm)
        }
        .fileExporter(isPresented: $showBackupExport, document: backupDocument, contentType: .finanzBackup, defaultFilename: "FinanzApp-backup") { result in
            if case .failure = result {
                backupResultMessage = L.backupCreateError
                showBackupResult = true
            }
        }
        .fileImporter(isPresented: $showBackupImporter, allowedContentTypes: [.finanzBackup, .json, .plainText]) { result in
            // The completion handler fires while the document picker is still dismissing;
            // presenting a new alert synchronously here gets silently dropped by SwiftUI, so
            // the follow-up alert is scheduled on the next run loop turn instead.
            func present(_ action: @escaping () -> Void) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: action)
            }
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let content = try? String(contentsOf: url, encoding: .utf8) {
                    pendingRestoreJSON = content
                    present { showRestoreConfirm = true }
                } else {
                    backupResultMessage = L.backupReadError
                    present { showBackupResult = true }
                }
            case .failure:
                backupResultMessage = L.fileOpenError
                present { showBackupResult = true }
            }
        }
        .fileImporter(isPresented: $showBackupFolderPicker, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                vm.setAutoBackupFolder(url)
            }
        }
        .alert(L.restoreConfirmTitle, isPresented: $showRestoreConfirm) {
            Button(L.cancel, role: .cancel) { pendingRestoreJSON = nil }
            Button(L.restoreBackup, role: .destructive) {
                if let json = pendingRestoreJSON, vm.restoreBackup(json) {
                    backupResultMessage = L.backupRestoreSuccess
                } else {
                    backupResultMessage = L.backupRestoreError
                }
                pendingRestoreJSON = nil
                showBackupResult = true
            }
        } message: {
            Text(L.restoreConfirmMessage)
        }
        .alert(L.backup, isPresented: $showBackupResult) {
            Button(L.ok, role: .cancel) {}
        } message: {
            Text(backupResultMessage)
        }
        .alert(L.notificationsDisabledTitle, isPresented: $showReminderDeniedAlert) {
            Button(L.openSettings) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(L.cancel, role: .cancel) {}
        } message: {
            Text(L.notificationsDisabledMessage)
        }
        .alert(L.notificationsDisabledTitle, isPresented: $showExpenseAlertDeniedAlert) {
            Button(L.openSettings) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(L.cancel, role: .cancel) {}
        } message: {
            Text(L.notificationsDisabledMessage)
        }
    }

    private var header: some View {
        HStack {
            Text(L.settings)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(AppColors.text)
                .tracking(-0.2)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private var budgetSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.budgetLevelSection)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(AppColors.primary.opacity(0.18)).frame(width: 40, height: 40)
                            Text("\(vm.currentLevel)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.primary)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(L.levelLabel(vm.currentLevel))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.text)
                            Text(L.xpTotal(Int(vm.totalXP)))
                                .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider().background(AppColors.divider).padding(.leading, 52)

                    SettingsRow(icon: "target", label: L.monthlyBudget) {
                        showBudgetEdit = true
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 18)

            SectionLabel(L.backTapSection)
            GlassView(radius: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L.backTapInstructions)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text(L.openSettings)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 18)
        }
    }

    private var appearanceSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.appearance)
            GlassView(radius: 28) {
                HStack {
                    Image(systemName: "moon.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85))
                    Text(L.darkTheme)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.text)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { vm.isDarkMode },
                        set: { vm.setDarkMode($0) }
                    ))
                    .labelsHidden()
                    .tint(AppColors.primary)
                }
                .padding(16)
            }
            .padding(.horizontal, 18)
        }
    }

    private var regionSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.region)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "globe").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85)).frame(width: 20)
                        Text(L.language)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Menu {
                            ForEach(AppLanguage.allCases) { lang in
                                Button {
                                    vm.setLanguage(lang.rawValue)
                                } label: {
                                    if lang == vm.currentLanguage {
                                        Label(lang.nativeName, systemImage: "checkmark")
                                    } else {
                                        Text(lang.nativeName)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(vm.currentLanguage.nativeName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.textSecondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                        }
                    }
                    .padding(16)

                    Divider().background(AppColors.divider).padding(.leading, 52)

                    HStack {
                        Image(systemName: "banknote.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85)).frame(width: 20)
                        Text(L.currency)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Menu {
                            ForEach(SUPPORTED_CURRENCIES) { cur in
                                Button {
                                    vm.setCurrency(cur.code)
                                } label: {
                                    if cur.code == vm.currencyCode {
                                        Label("\(cur.code) (\(cur.symbol))", systemImage: "checkmark")
                                    } else {
                                        Text("\(cur.code) (\(cur.symbol))")
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(vm.currencyCode)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.textSecondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private var reminderSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.reminder)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "alarm.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85))
                        Text(L.dailyReminder)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { reminderEnabled },
                            set: { handleReminderToggle($0) }
                        ))
                        .labelsHidden()
                        .tint(AppColors.primary)
                    }
                    .padding(16)

                    if reminderEnabled {
                        Divider().background(AppColors.divider).padding(.leading, 52)
                        HStack {
                            Text(L.time)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            Spacer()
                            DatePicker("", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .tint(AppColors.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.horizontal, 18)
            Text(L.reminderHint)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 24)
        }
    }

    private var expenseAlertSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.expenseAlerts)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85))
                        Text(L.expenseAlertsToggle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { vm.expenseAlertsEnabled },
                            set: { handleExpenseAlertToggle($0) }
                        ))
                        .labelsHidden()
                        .tint(AppColors.primary)
                    }
                    .padding(16)

                    if vm.expenseAlertsEnabled {
                        ForEach(vm.expenseAlertThresholds, id: \.self) { threshold in
                            Divider().background(AppColors.divider).padding(.leading, 52)
                            thresholdRow(threshold)
                        }
                        Divider().background(AppColors.divider).padding(.leading, 52)
                        addThresholdRow
                    }
                }
            }
            .padding(.horizontal, 18)
            Text(L.expenseAlertsHint)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 24)
        }
    }

    private func thresholdRow(_ threshold: Int) -> some View {
        let isCustom = !AppViewModel.defaultExpenseAlertThresholds.contains(threshold)
        return HStack {
            Button {
                vm.setThreshold(threshold, enabled: !vm.isThresholdEnabled(threshold))
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: vm.isThresholdEnabled(threshold) ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundStyle(vm.isThresholdEnabled(threshold) ? AppColors.primary : AppColors.textTertiary)
                    Text("\(threshold)%")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.text)
                }
            }
            Spacer()
            if isCustom {
                Button {
                    vm.removeCustomThreshold(threshold)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var addThresholdRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle").font(.system(size: 16)).foregroundStyle(AppColors.textTertiary)
            TextField(L.thresholdPlaceholder, text: $newThresholdText)
                .keyboardType(.numberPad)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.text)
            Spacer()
            Button(L.addCustomThreshold) {
                if let value = Int(newThresholdText) {
                    vm.addCustomThreshold(value)
                }
                newThresholdText = ""
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(AppColors.primary)
            .disabled(Int(newThresholdText) == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func handleExpenseAlertToggle(_ enabled: Bool) {
        if enabled {
            NotificationManager.requestAuthorization { granted in
                if granted {
                    vm.setExpenseAlertsEnabled(true)
                } else {
                    vm.setExpenseAlertsEnabled(false)
                    showExpenseAlertDeniedAlert = true
                }
            }
        } else {
            vm.setExpenseAlertsEnabled(false)
        }
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = reminderHour; c.minute = reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = c.hour ?? 20
                reminderMinute = c.minute ?? 0
                NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            }
        )
    }

    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            NotificationManager.requestAuthorization { granted in
                if granted {
                    reminderEnabled = true
                    NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                } else {
                    reminderEnabled = false
                    showReminderDeniedAlert = true
                }
            }
        } else {
            reminderEnabled = false
            NotificationManager.cancelReminder()
        }
    }

    private var managementSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.management)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    SettingsRow(icon: "tag.fill", label: L.categories) {
                        showCategoryManager = true
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 18)
        }
    }

    private var backupSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.backup)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    SettingsRow(icon: "externaldrive.fill", label: L.createBackup) {
                        backupDocument = TextFileDocument(text: vm.createBackup())
                        showBackupExport = true
                    }
                    Divider().background(AppColors.divider).padding(.leading, 52)
                    SettingsRow(icon: "arrow.uturn.backward.circle.fill", label: L.restoreBackup) {
                        showBackupImporter = true
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 18)
            Text(L.backupHint)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 24)
        }
    }

    private var autoBackupSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.autoBackupSection)
            GlassView(radius: 28) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85))
                        Text(L.autoBackup)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { vm.autoBackupEnabled },
                            set: { vm.setAutoBackupEnabled($0) }
                        ))
                        .labelsHidden()
                        .tint(AppColors.primary)
                    }
                    .padding(16)

                    if vm.autoBackupEnabled {
                        Divider().background(AppColors.divider).padding(.leading, 52)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L.backupFrequency)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            HStack(spacing: 8) {
                                ForEach(BackupFrequency.allCases, id: \.self) { freq in
                                    Text(freq.label)
                                        .font(.system(size: 12.5, weight: .bold))
                                        .foregroundStyle(vm.autoBackupFrequency == freq ? Color(hex: "#0B1120") : AppColors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(vm.autoBackupFrequency == freq ? Color.white.opacity(0.9) : AppColors.glass)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .onTapGesture { vm.setAutoBackupFrequency(freq) }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider().background(AppColors.divider).padding(.leading, 52)
                        HStack {
                            Image(systemName: "folder.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(AppColors.text.opacity(0.85)).frame(width: 20)
                            Text(L.backupFolder)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColors.text)
                            Spacer()
                            Menu {
                                Button(L.chooseFolder) { showBackupFolderPicker = true }
                                if vm.autoBackupFolderName != nil {
                                    Button(L.backupFolderDefault, role: .destructive) { vm.clearAutoBackupFolder() }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(vm.autoBackupFolderName ?? L.backupFolderDefault)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .lineLimit(1)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .padding(.horizontal, 18)
            Text(L.backupFolderHint)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 24)
            Text(L.autoBackupHint)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, 24)
        }
    }

    private var infoSection: some View {
        VStack(spacing: 8) {
            SectionLabel(L.info)
            GlassView(radius: 28) {
                VStack(spacing: 12) {
                    InfoRow(label: L.version, value: "6.0.0")
                    Divider().background(AppColors.divider)
                    AppLogo()
                        .padding(.vertical, 8)
                }
                .padding(16)
            }
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Backup file document

extension UTType {
    static var finanzBackup: UTType {
        UTType(exportedAs: "com.finanzapp.backup", conformingTo: .json)
    }
}

struct TextFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.finanzBackup, .json, .plainText] }
    static var writableContentTypes: [UTType] { [.finanzBackup] }

    var text: String
    init(text: String) { self.text = text }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents, let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let label: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.text.opacity(0.85))
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Remainder of existing helpers (unchanged)

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(AppColors.text)
        }
    }
}

// MARK: - Category Manager

struct CategoryManagerView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddSheet = false
    @State private var editingCategory: Category?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.bg.first!.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        SectionLabel(L.expenses.uppercased())
                        GlassView(radius: 28) {
                            VStack(spacing: 0) {
                                ForEach(vm.categories.filter { $0.type == "expense" }) { cat in
                                    CategoryRow(category: cat, onEdit: { editingCategory = cat }, onDelete: { vm.deleteCategory(id: cat.id) })
                                    if cat.id != vm.categories.filter({ $0.type == "expense" }).last?.id {
                                        Divider().background(AppColors.divider)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal, 16)

                        SectionLabel(L.incomes.uppercased())
                        GlassView(radius: 28) {
                            VStack(spacing: 0) {
                                ForEach(vm.categories.filter { $0.type == "income" }) { cat in
                                    CategoryRow(category: cat, onEdit: { editingCategory = cat }, onDelete: { vm.deleteCategory(id: cat.id) })
                                    if cat.id != vm.categories.filter({ $0.type == "income" }).last?.id {
                                        Divider().background(AppColors.divider)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal, 16)

                        Button { showAddSheet = true } label: {
                            GlassView(intensity: .strong, radius: 18) {
                                HStack {
                                    Image(systemName: "plus.circle.fill").foregroundStyle(AppColors.primary)
                                    Text(L.addCategory).font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.primary)
                                    Spacer()
                                }
                                .padding(16)
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle(L.manageCategories)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button(L.close) { dismiss() }.foregroundStyle(AppColors.primary) } }
            .sheet(isPresented: $showAddSheet) { CategoryFormSheet(editingCategory: nil) }
            .sheet(item: $editingCategory) { cat in CategoryFormSheet(editingCategory: cat) }
        }
    }
}

struct CategoryFormSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let editingCategory: Category?

    @State private var name: String
    @State private var type: String
    @State private var color: String
    @State private var icon: String

    init(editingCategory: Category?) {
        self.editingCategory = editingCategory
        _name = State(initialValue: editingCategory?.name ?? "")
        _type = State(initialValue: editingCategory?.type ?? "expense")
        _color = State(initialValue: editingCategory?.color ?? "#757575")
        _icon = State(initialValue: editingCategory?.icon ?? "")
    }

    private let presetColors = ["#E53935","#1E88E5","#8E24AA","#D81B60","#FB8C00","#00ACC1","#43A047","#F4511E","#5E35B1","#757575","#2E7D32","#00838F","#1565C0","#6A1B9A"]

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.bg.first!.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        FormField(L.name) {
                            GlassView(intensity: .strong, radius: 18) {
                                TextField(L.categoryName, text: $name)
                                    .font(.system(size: 16)).foregroundStyle(AppColors.text).padding(16)
                            }
                        }
                        FormField(L.icon) {
                            GlassView(intensity: .strong, radius: 18) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color(hex: color).opacity(0.28)).frame(width: 40, height: 40)
                                        if icon.isEmpty {
                                            Image(systemName: "tag.fill").font(.system(size: 16, weight: .medium)).foregroundStyle(Color(hex: color))
                                        } else {
                                            CategoryIconView(icon: icon, size: 18).foregroundStyle(Color(hex: color))
                                        }
                                    }
                                    TextField(L.iconPlaceholder, text: $icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(AppColors.text)
                                        .onChange(of: icon) { _, newValue in
                                            // This trims keyboard-typed emoji to 2 characters, but
                                            // must never touch a value set by tapping a grid icon
                                            // below (e.g. "cart.fill") — truncating those mangled
                                            // the SF Symbol name so it silently failed to render.
                                            guard !CATEGORY_ICON_CHOICES.contains(newValue) else { return }
                                            if newValue.count > 2 { icon = String(newValue.suffix(2)) }
                                        }
                                    Spacer()
                                    if !icon.isEmpty {
                                        Button { icon = "" } label: {
                                            Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.textTertiary)
                                        }
                                    }
                                }
                                .padding(16)
                            }
                            Text(L.iconHint)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)

                            GlassView(radius: 18) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(CATEGORY_ICON_CHOICES, id: \.self) { i in
                                        Button { icon = i } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(icon == i ? Color(hex: color).opacity(0.35) : AppColors.glass)
                                                    .frame(width: 38, height: 38)
                                                    .overlay(Circle().stroke(icon == i ? Color(hex: color) : Color.clear, lineWidth: 2))
                                                Image(systemName: i)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(icon == i ? Color(hex: color) : AppColors.textSecondary)
                                            }
                                        }
                                    }
                                }
                                .padding(14)
                            }
                        }
                        FormField(L.type) {
                            HStack(spacing: 8) {
                                ForEach(["expense", "income"], id: \.self) { t in
                                    Button { type = t } label: {
                                        Text(t == "expense" ? L.expense : L.income)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(type == t ? .black : AppColors.textSecondary)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(type == t ? Color.white.opacity(0.92) : AppColors.glass)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        FormField(L.color) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                ForEach(presetColors, id: \.self) { c in
                                    Circle().fill(Color(hex: c)).frame(width: 32, height: 32)
                                        .overlay(Circle().stroke(color == c ? AppColors.text : Color.clear, lineWidth: 2))
                                        .onTapGesture { color = c }
                                }
                            }
                        }
                        Button {
                            if let existing = editingCategory {
                                var updated = existing
                                updated.name = name
                                updated.icon = icon.isEmpty ? "tag" : icon
                                updated.color = color
                                updated.type = type
                                vm.updateCategory(updated)
                            } else {
                                vm.addCategory(name: name, type: type, color: color, icon: icon)
                            }
                            dismiss()
                        } label: {
                            Text(editingCategory == nil ? L.add : L.save)
                                .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(!name.isEmpty ? AppColors.primary : AppColors.textTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .disabled(name.isEmpty)
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16).padding(.top, 12)
                }
            }
            .navigationTitle(editingCategory == nil ? L.newCategory : L.editCategory).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button(L.cancel) { dismiss() }.foregroundStyle(AppColors.textSecondary) } }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        // A `Button` nested inside another `Button`'s label breaks hit-testing in SwiftUI —
        // the outer button silently stops receiving taps. `.onTapGesture` on the row plus a
        // single real `Button` for delete avoids that entirely.
        HStack(spacing: 12) {
            CategoryIconView(icon: resolvedIcon(for: category), size: 15)
                .foregroundStyle(category.displayColor)
                .frame(width: 20)
            Text(L.categoryName(category.name)).font(.system(size: 15, weight: .medium)).foregroundStyle(AppColors.text)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textTertiary)
            Button(action: onDelete) {
                Image(systemName: "trash").font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.expense.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture(perform: onEdit)
    }
}

// MARK: - Helpers

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack { Text(text).font(.system(size: 11, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.8); Spacer() }
        .padding(.horizontal, 22)
    }
}

struct FormField<Content: View>: View {
    let label: String
    let content: Content
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12, weight: .bold)).foregroundStyle(AppColors.textTertiary).tracking(0.5)
            content
        }
    }
}
