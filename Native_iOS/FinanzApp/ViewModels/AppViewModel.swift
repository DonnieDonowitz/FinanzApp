import Foundation
import Combine
import WidgetKit

enum BackupFrequency: String, CaseIterable {
    case daily, weekly, monthly

    var label: String {
        switch self {
        case .daily: return L.daily
        case .weekly: return L.weekly
        case .monthly: return L.monthly
        }
    }

    var minimumDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        }
    }
}

final class AppViewModel: ObservableObject {
    @Published var categories: [Category] = [] { didSet { recomputeMonthlyCache() } }
    @Published var transactions: [Transaction] = [] { didSet { recomputeMonthlyCache() } }
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var isLoading = true
    @Published var pendingQuickAddType: String?
    @Published var isDarkMode: Bool = UserDefaults.standard.string(forKey: "themeMode") != "light"
    @Published var languageCode: String = AppSettingsStore.languageCode
    @Published var currencyCode: String = AppSettingsStore.currencyCode

    func setDarkMode(_ dark: Bool) {
        isDarkMode = dark
        UserDefaults.standard.set(dark ? "dark" : "light", forKey: "themeMode")
        // Widgets run in a separate process and can't read the app's own theme toggle directly,
        // only the App Group suite — mirror it there so widgets match the app instead of the
        // system-wide appearance.
        sharedSettingsDefaults.set(dark ? "dark" : "light", forKey: "themeMode")
        WidgetCenter.shared.reloadAllTimelines()
    }

    var currentLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .en
    }

    func setLanguage(_ code: String) {
        languageCode = code
        sharedSettingsDefaults.set(code, forKey: "languageCode")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func setCurrency(_ code: String) {
        currencyCode = code
        sharedSettingsDefaults.set(code, forKey: "currencyCode")
        WidgetCenter.shared.reloadAllTimelines()
    }

    @Published var expenseAlertsEnabled: Bool = UserDefaults.standard.bool(forKey: "expenseAlertsEnabled")

    func setExpenseAlertsEnabled(_ enabled: Bool) {
        expenseAlertsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "expenseAlertsEnabled")
    }

    /// The thresholds offered out of the box; always present in `expenseAlertThresholds` and
    /// never removable, though the user can still uncheck them individually.
    static let defaultExpenseAlertThresholds = [50, 75, 90, 100]

    @Published var expenseAlertThresholds: [Int] = (UserDefaults.standard.array(forKey: "expenseAlertThresholdsList") as? [Int] ?? AppViewModel.defaultExpenseAlertThresholds).sorted()

    @Published var enabledExpenseAlertThresholds: Set<Int> = Set(
        UserDefaults.standard.array(forKey: "enabledExpenseAlertThresholds") as? [Int] ?? AppViewModel.defaultExpenseAlertThresholds
    )

    func isThresholdEnabled(_ threshold: Int) -> Bool {
        enabledExpenseAlertThresholds.contains(threshold)
    }

    func setThreshold(_ threshold: Int, enabled: Bool) {
        if enabled { enabledExpenseAlertThresholds.insert(threshold) } else { enabledExpenseAlertThresholds.remove(threshold) }
        UserDefaults.standard.set(Array(enabledExpenseAlertThresholds), forKey: "enabledExpenseAlertThresholds")
    }

    func addCustomThreshold(_ threshold: Int) {
        guard threshold > 0, threshold <= 1000, !expenseAlertThresholds.contains(threshold) else { return }
        expenseAlertThresholds.append(threshold)
        expenseAlertThresholds.sort()
        UserDefaults.standard.set(expenseAlertThresholds, forKey: "expenseAlertThresholdsList")
        setThreshold(threshold, enabled: true)
    }

    func removeCustomThreshold(_ threshold: Int) {
        guard !Self.defaultExpenseAlertThresholds.contains(threshold) else { return }
        expenseAlertThresholds.removeAll { $0 == threshold }
        UserDefaults.standard.set(expenseAlertThresholds, forKey: "expenseAlertThresholdsList")
        setThreshold(threshold, enabled: false)
    }

    private func checkExpenseAlertThresholds() {
        guard expenseAlertsEnabled, monthIncome > 0 else { return }
        let percent = Int(monthExpense / monthIncome * 100)
        let key = "notifiedThresholds_\(Date.currentMonth)"
        var notified = Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
        var didNotify = false
        for threshold in expenseAlertThresholds where enabledExpenseAlertThresholds.contains(threshold) && percent >= threshold && !notified.contains(threshold) {
            NotificationManager.sendExpenseAlert(percent: percent)
            notified.insert(threshold)
            didNotify = true
        }
        if didNotify {
            UserDefaults.standard.set(Array(notified), forKey: key)
        }
    }

    let db = DatabaseManager.shared

    init() { load() }

    func load() {
        categories = db.getAllCategories()
        transactions = db.getAllTransactions()
        recurringTransactions = db.getAllRecurring()
        processRecurringIfNeeded()
        isLoading = false
        performAutoBackupIfNeeded()
    }

    func refresh() {
        categories = db.getAllCategories()
        transactions = db.getAllTransactions()
        recurringTransactions = db.getAllRecurring()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Computed properties

    /// Cached in `recomputeMonthlyCache()`, not recomputed per read — these used to be plain
    /// computed `var`s that each re-filtered the *entire* transaction list, and several were
    /// re-derived from one another (e.g. `topCategories` re-filtered inside a per-category loop),
    /// so a single HomeView render could re-scan all transactions dozens of times. That's what
    /// made saving a transaction (which re-renders Home right after) feel slow with real data.
    private(set) var monthTransactions: [Transaction] = []
    private(set) var monthIncome: Double = 0
    private(set) var monthExpense: Double = 0
    private(set) var topCategories: [TopCategory] = []
    private(set) var dailyAverageExpense: Double = 0
    private(set) var expenseRatio: Double = 0

    var monthBalance: Double { monthIncome - monthExpense }

    var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }

    private func recomputeMonthlyCache() {
        let month = Date.currentMonth
        var monthTx: [Transaction] = []
        var income = 0.0
        var expense = 0.0
        var categoryTotals: [Int64: Double] = [:]

        for tx in transactions where tx.date.hasPrefix(month) {
            monthTx.append(tx)
            if tx.type == "income" {
                income += tx.amount
            } else {
                expense += tx.amount
                if let catId = tx.categoryId { categoryTotals[catId, default: 0] += tx.amount }
            }
        }

        monthTransactions = monthTx
        monthIncome = income
        monthExpense = expense
        topCategories = categoryTotals.compactMap { catId, amount -> TopCategory? in
            guard let cat = categoryById(catId) else { return nil }
            return TopCategory(id: catId, name: cat.name, amount: amount, percentage: expense > 0 ? amount / expense * 100 : 0)
        }
        .sorted { $0.amount > $1.amount }
        .prefix(3)
        .map { $0 }

        let days = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
        dailyAverageExpense = expense / Double(days)
        expenseRatio = income > 0 ? expense / income : 0
    }

    func categoryById(_ id: Int64?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    func transactionsForMonth(_ month: String) -> [Transaction] {
        transactions.filter { $0.date.hasPrefix(month) }
    }

    func transactionsForPeriod(start: String, end: String) -> [Transaction] {
        transactions.filter { $0.date >= start && $0.date <= end }
    }

    func incomeForMonth(_ month: String) -> Double {
        transactionsForMonth(month).filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }

    func expenseForMonth(_ month: String) -> Double {
        transactionsForMonth(month).filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    func balanceForMonth(_ month: String) -> Double {
        incomeForMonth(month) - expenseForMonth(month)
    }

    func incomeForYear(_ year: String) -> Double {
        transactions.filter { $0.date.hasPrefix(year) && $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }

    func expenseForYear(_ year: String) -> Double {
        transactions.filter { $0.date.hasPrefix(year) && $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    func balanceForYear(_ year: String) -> Double {
        incomeForYear(year) - expenseForYear(year)
    }

    func categorySpent(_ month: String, categoryId: Int64) -> Double {
        transactionsForMonth(month).filter { $0.categoryId == categoryId && $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Transactions

    func addTransaction(type: String, amount: Double, description: String, categoryId: Int64, categoryName: String, date: String) {
        let tx = Transaction(amount: amount, description: description, categoryId: categoryId, date: date, type: type, recurringId: nil)
        var inserted = tx
        inserted.id = db.addTransaction(tx)
        transactions.insert(inserted, at: 0)
        checkExpenseAlertThresholds()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateTransaction(_ t: Transaction) {
        db.updateTransaction(t)
        refresh()
    }

    func deleteTransaction(_ id: Int64) {
        db.deleteTransaction(id)
        transactions.removeAll { $0.id == id }
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Categories

    func addCategory(name: String, type: String, color: String, icon: String = "tag") {
        let c = Category(name: name, icon: icon.isEmpty ? "tag" : icon, color: color, type: type, isDefault: false)
        _ = db.addCategory(c)
        refresh()
    }

    func deleteCategory(id: Int64) {
        db.deleteCategory(id)
        refresh()
    }

    func updateCategory(_ c: Category) {
        db.updateCategory(c)
        refresh()
    }

    // MARK: - Recurring

    func addRecurring(type: String, amount: Double, description: String, categoryId: Int64, categoryName: String, frequency: String, nextDueDate: String) {
        let r = RecurringTransaction(amount: amount, description: description, categoryId: categoryId, type: type, frequency: frequency, startDate: Date.currentString, endDate: nil, nextDueDate: nextDueDate, active: true)
        var inserted = r
        inserted.id = db.addRecurring(r)
        recurringTransactions.append(inserted)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateRecurring(_ r: RecurringTransaction) {
        db.updateRecurring(r)
        refresh()
    }

    func deleteRecurring(_ id: Int64) {
        db.deleteRecurring(id)
        recurringTransactions.removeAll { $0.id == id }
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Auto-process recurring

    func processRecurringIfNeeded() {
        let today = Date.currentString
        let active = db.getActiveRecurring()
        var processed = false
        for r in active {
            guard r.nextDueDate <= today else { continue }
            let tx = Transaction(amount: r.amount, description: r.description, categoryId: r.categoryId, date: today, type: r.type, recurringId: r.id)
            db.addTransaction(tx)
            let next = Scheduling.getNextDueDate(currentDueDate: r.nextDueDate, frequency: r.frequency)
            let stillActive = r.endDate == nil || next <= (r.endDate ?? "")
            db.exec("UPDATE recurring_transactions SET next_due_date = ?, active = ? WHERE id = ?", [next, stillActive ? 1 : 0, r.id])
            processed = true
        }
        if processed {
            refresh()
            checkExpenseAlertThresholds()
        }
    }

    // MARK: - Backup / Restore

    func createBackup() -> String {
        db.backupToSQL()
    }

    func restoreBackup(_ content: String) -> Bool {
        guard db.restoreFromBackup(content) else { return false }
        setDarkMode(db.getSetting("theme") != "light")
        refresh()
        return true
    }

    // MARK: - Automatic backup

    @Published var autoBackupEnabled: Bool = UserDefaults.standard.bool(forKey: "autoBackupEnabled")
    @Published var autoBackupFrequency: BackupFrequency = BackupFrequency(
        rawValue: UserDefaults.standard.string(forKey: "autoBackupFrequency") ?? ""
    ) ?? .weekly

    func setAutoBackupEnabled(_ enabled: Bool) {
        autoBackupEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "autoBackupEnabled")
        if enabled { performAutoBackupIfNeeded(force: true) }
    }

    func setAutoBackupFrequency(_ frequency: BackupFrequency) {
        autoBackupFrequency = frequency
        UserDefaults.standard.set(frequency.rawValue, forKey: "autoBackupFrequency")
    }

    /// Display name of the user-chosen backup folder, or `nil` when none has been picked yet
    /// (falls back to the app's own sandboxed folder — see `autoBackupsDirectory`).
    @Published var autoBackupFolderName: String? = UserDefaults.standard.string(forKey: "autoBackupFolderName")

    /// Persists a security-scoped bookmark for `url` so automatic backups can keep writing to
    /// it across app launches without a fresh picker prompt every time. A user-chosen folder
    /// (e.g. iCloud Drive) matters because the app's own sandboxed Documents folder is wiped
    /// whenever this unsigned/ad-hoc build gets re-sideloaded — which silently destroyed every
    /// automatic backup on each reinstall even though the write itself never failed.
    func setAutoBackupFolder(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let bookmark = try? url.bookmarkData() else { return }
        UserDefaults.standard.set(bookmark, forKey: "autoBackupFolderBookmark")
        UserDefaults.standard.set(url.lastPathComponent, forKey: "autoBackupFolderName")
        autoBackupFolderName = url.lastPathComponent
        performAutoBackupIfNeeded(force: true)
    }

    func clearAutoBackupFolder() {
        UserDefaults.standard.removeObject(forKey: "autoBackupFolderBookmark")
        UserDefaults.standard.removeObject(forKey: "autoBackupFolderName")
        autoBackupFolderName = nil
    }

    private func resolvedAutoBackupFolder() -> URL? {
        guard let bookmark = UserDefaults.standard.data(forKey: "autoBackupFolderBookmark") else { return nil }
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: bookmark, options: [], relativeTo: nil, bookmarkDataIsStale: &stale) else { return nil }
        return url
    }

    /// The on-device folder automatic backups fall back to when the user hasn't chosen one —
    /// inside the app's own Documents directory, which `UIFileSharingEnabled`/
    /// `LSSupportsOpeningDocumentsInPlace` expose under "On My iPhone → FinanzApp" in the Files
    /// app. Unlike a user-chosen folder, this one does not survive a reinstall.
    private var autoBackupsDirectory: URL? {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let dir = docs.appendingPathComponent("AutoBackups", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Writes a new automatic backup if enough time has passed since the last one for the
    /// chosen frequency. Called on every launch (there's no real background execution for a
    /// simple local app like this), so a backup lands the next time the app is opened after
    /// its interval elapses — not at an exact scheduled time.
    func performAutoBackupIfNeeded(force: Bool = false) {
        guard autoBackupEnabled else { return }
        let key = "lastAutoBackupDate"
        let now = Date()
        if !force, let last = UserDefaults.standard.object(forKey: key) as? Date {
            let days = Calendar.current.dateComponents([.day], from: last, to: now).day ?? Int.max
            guard days >= autoBackupFrequency.minimumDays else { return }
        }

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd-HHmmss"
        f.locale = Locale(identifier: "en_US_POSIX")
        let filename = "FinanzApp-backup-\(f.string(from: now)).finanz"

        if let folder = resolvedAutoBackupFolder() {
            guard folder.startAccessingSecurityScopedResource() else { return }
            defer { folder.stopAccessingSecurityScopedResource() }
            writeAutoBackup(to: folder.appendingPathComponent(filename), cleanupDir: folder, dateKey: key, now: now)
        } else if let dir = autoBackupsDirectory {
            writeAutoBackup(to: dir.appendingPathComponent(filename), cleanupDir: dir, dateKey: key, now: now)
        }
    }

    /// Only advances `lastAutoBackupDate` when the write actually succeeds — previously it was
    /// stamped unconditionally right after a `try?` write, so a silent failure (revoked folder
    /// access, disk error, anything) still marked that day's backup as "done" and the app would
    /// not attempt another one until the next interval, with nothing ever having been written.
    private func writeAutoBackup(to fileURL: URL, cleanupDir: URL, dateKey: String, now: Date) {
        guard (try? createBackup().write(to: fileURL, atomically: true, encoding: .utf8)) != nil else { return }
        UserDefaults.standard.set(now, forKey: dateKey)
        cleanupOldAutoBackups(in: cleanupDir)
    }

    private func cleanupOldAutoBackups(in dir: URL, keep: Int = 10) {
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        let sorted = files.sorted { a, b in
            let da = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let db = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return da > db
        }
        for file in sorted.dropFirst(keep) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

// MARK: - TopCategory

struct TopCategory: Identifiable {
    let id: Int64
    let name: String
    let amount: Double
    let percentage: Double
}