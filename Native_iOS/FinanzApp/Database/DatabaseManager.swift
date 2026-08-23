import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private let appGroupID = "group.com.finanzapp.app"

    private var dbPath: String {
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return groupURL.appendingPathComponent("finanzapp.db").path
        }
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return (paths.first! as NSString).appendingPathComponent("finanzapp.db")
    }

    private init() {
        openDatabase()
        createTables()
        seedData()
    }

    deinit {
        if let db = db { sqlite3_close(db) }
    }

    // MARK: - Open

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database at \(dbPath)")
        }
    }

    // MARK: - Schema

    private func createTables() {
        let sql = """
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            icon TEXT NOT NULL DEFAULT 'tag',
            color TEXT NOT NULL DEFAULT '#6200EE',
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')) DEFAULT 'expense',
            is_default INTEGER NOT NULL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL CHECK(amount > 0),
            description TEXT NOT NULL DEFAULT '',
            category_id INTEGER,
            date TEXT NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
            recurring_id INTEGER,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
            FOREIGN KEY (recurring_id) REFERENCES recurring_transactions(id) ON DELETE SET NULL
        );
        CREATE TABLE IF NOT EXISTS recurring_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL CHECK(amount > 0),
            description TEXT NOT NULL DEFAULT '',
            category_id INTEGER,
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
            frequency TEXT NOT NULL CHECK(frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
            start_date TEXT NOT NULL,
            end_date TEXT,
            next_due_date TEXT NOT NULL,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
        );
        CREATE TABLE IF NOT EXISTS app_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
        CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
        CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);
        CREATE INDEX IF NOT EXISTS idx_recurring_next_due ON recurring_transactions(next_due_date);
        """
        // `exec` only compiles the first statement in a string (sqlite3_prepare_v2 stops at the
        // first ';'), which silently dropped every table after `categories` here; execScript runs
        // the whole multi-statement script via sqlite3_exec instead.
        execScript(sql)
    }

    // MARK: - Seed

    private func seedData() {
        let count = queryInt("SELECT COUNT(*) as c FROM categories")
        if count > 0 { return }

        let expenseCats: [(String, String)] = [
            ("Alimentari", "#E53935"), ("Trasporti", "#1E88E5"), ("Abitazione", "#8E24AA"),
            ("Salute", "#D81B60"), ("Intrattenimento", "#FB8C00"), ("Abbigliamento", "#00ACC1"),
            ("Educazione", "#43A047"), ("Ristoranti", "#F4511E"), ("Bollette", "#5E35B1"),
            ("Altro", "#757575")
        ]
        let incomeCats: [(String, String)] = [
            ("Stipendio", "#2E7D32"), ("Freelance", "#00838F"),
            ("Investimenti", "#1565C0"), ("Altro", "#6A1B9A")
        ]

        for (name, color) in expenseCats {
            exec("INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, 'expense', 1)", [name, "tag", color])
        }
        for (name, color) in incomeCats {
            exec("INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, 'income', 1)", [name, "tag", color])
        }

        let settingsCount = queryInt("SELECT COUNT(*) as c FROM app_settings")
        if settingsCount == 0 {
            exec("INSERT INTO app_settings (key, value) VALUES ('theme', 'light')")
        }
    }

    // MARK: - Raw Execute

    @discardableResult
    func exec(_ sql: String, _ params: [Any] = []) -> Bool {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("prepare error: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        bindParams(stmt: stmt, params: params)
        let result = sqlite3_step(stmt) == SQLITE_DONE
        sqlite3_finalize(stmt)
        return result
    }

    /// Runs a full multi-statement script (e.g. `PRAGMA ...; BEGIN TRANSACTION; ...; COMMIT;`)
    /// in one call, as opposed to `exec(_:_:)` which prepares a single parameterized statement.
    @discardableResult
    private func execScript(_ sql: String) -> Bool {
        var errMsg: UnsafeMutablePointer<Int8>?
        let result = sqlite3_exec(db, sql, nil, nil, &errMsg)
        if let errMsg {
            print("execScript error: \(String(cString: errMsg))")
            sqlite3_free(errMsg)
        }
        return result == SQLITE_OK
    }

    private func bindParams(stmt: OpaquePointer?, params: [Any]) {
        for (i, param) in params.enumerated() {
            let idx = Int32(i + 1)
            switch param {
            case let v as Int:   sqlite3_bind_int(stmt, idx, Int32(v))
            case let v as Int64: sqlite3_bind_int64(stmt, idx, v)
            case let v as Double: sqlite3_bind_double(stmt, idx, v)
            case let v as String: sqlite3_bind_text(stmt, idx, (v as NSString).utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            case let v as Bool:  sqlite3_bind_int(stmt, idx, v ? 1 : 0)
            default: sqlite3_bind_null(stmt, idx)
            }
        }
    }

    private func queryInt(_ sql: String, _ params: [Any] = []) -> Int {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        bindParams(stmt: stmt, params: params)
        var result = 0
        if sqlite3_step(stmt) == SQLITE_ROW { result = Int(sqlite3_column_int(stmt, 0)) }
        sqlite3_finalize(stmt)
        return result
    }

    func lastInsertRowId() -> Int64 {
        sqlite3_last_insert_rowid(db)
    }

    func queryRows(_ sql: String, _ params: [Any] = []) -> [[Any?]] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("query error: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }
        bindParams(stmt: stmt, params: params)
        var results: [[Any?]] = []
        let colCount = sqlite3_column_count(stmt)
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [Any?] = []
            for i in 0..<colCount {
                switch sqlite3_column_type(stmt, i) {
                case SQLITE_INTEGER: row.append(sqlite3_column_int64(stmt, i))
                case SQLITE_FLOAT:   row.append(sqlite3_column_double(stmt, i))
                case SQLITE_TEXT:    row.append(String(cString: sqlite3_column_text(stmt, i)))
                case SQLITE_NULL:    row.append(nil)
                default:             row.append(nil)
                }
            }
            results.append(row)
        }
        sqlite3_finalize(stmt)
        return results
    }

    func querySingleValue(_ sql: String, _ params: [Any] = []) -> Any? {
        queryRows(sql, params).first?.first ?? nil
    }

    // MARK: - Categories

    func getAllCategories() -> [Category] {
        let rows = queryRows("SELECT id, name, icon, color, type, is_default FROM categories ORDER BY type, name")
        return rows.map { r in
            Category(id: r[0] as! Int64, name: r[1] as! String, icon: r[2] as! String, color: r[3] as! String,
                     type: r[4] as! String, isDefault: (r[5] as! Int64) == 1)
        }
    }

    func addCategory(_ c: Category) -> Int64 {
        exec("INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, ?, ?)",
             [c.name, c.icon, c.color, c.type, c.isDefault ? 1 : 0])
        return lastInsertRowId()
    }

    func updateCategory(_ c: Category) {
        exec("UPDATE categories SET name=?, icon=?, color=?, type=? WHERE id=?",
             [c.name, c.icon, c.color, c.type, c.id])
    }

    func deleteCategory(_ id: Int64) {
        exec("DELETE FROM categories WHERE id=?", [id])
    }

    func getCategoryCount() -> Int {
        queryInt("SELECT COUNT(*) FROM categories")
    }

    // MARK: - Transactions

    func getTransactions(month: String? = nil) -> [Transaction] {
        var sql = "SELECT id, amount, description, category_id, date, type, recurring_id FROM transactions"
        var params: [Any] = []
        if let m = month {
            sql += " WHERE date LIKE ?"
            params.append("\(m)%")
        }
        sql += " ORDER BY date DESC, id DESC"
        let rows = queryRows(sql, params)
        return rows.map { r in
            Transaction(id: r[0] as! Int64, amount: r[1] as! Double, description: r[2] as! String,
                        categoryId: r[3] as? Int64, date: r[4] as! String, type: r[5] as! String,
                        recurringId: r[6] as? Int64)
        }
    }

    func getTransactionsForMonth(_ month: String) -> [Transaction] {
        getTransactions(month: month)
    }

    func getTransactionsForYear(_ year: String) -> [Transaction] {
        let rows = queryRows("SELECT id, amount, description, category_id, date, type, recurring_id FROM transactions WHERE date LIKE ? ORDER BY date, id", ["\(year)%"])
        return rows.map { r in
            Transaction(id: r[0] as! Int64, amount: r[1] as! Double, description: r[2] as! String,
                        categoryId: r[3] as? Int64, date: r[4] as! String, type: r[5] as! String,
                        recurringId: r[6] as? Int64)
        }
    }

    func getTransactionsForPeriod(start: String, end: String) -> [Transaction] {
        let rows = queryRows("SELECT id, amount, description, category_id, date, type, recurring_id FROM transactions WHERE date >= ? AND date <= ? ORDER BY date DESC, id DESC", [start, end])
        return rows.map { r in
            Transaction(id: r[0] as! Int64, amount: r[1] as! Double, description: r[2] as! String,
                        categoryId: r[3] as? Int64, date: r[4] as! String, type: r[5] as! String,
                        recurringId: r[6] as? Int64)
        }
    }

    func getAllTransactions() -> [Transaction] { getTransactions(month: nil) }

    func getTransactionCount() -> Int {
        queryInt("SELECT COUNT(*) FROM transactions")
    }

    func getTransactionCountForMonth(_ month: String) -> Int {
        queryInt("SELECT COUNT(*) FROM transactions WHERE date LIKE ?", ["\(month)%"])
    }

    func addTransaction(_ t: Transaction) -> Int64 {
        exec("INSERT INTO transactions (amount, description, category_id, date, type, recurring_id) VALUES (?, ?, ?, ?, ?, ?)",
             [t.amount, t.description, t.categoryId ?? NSNull(), t.date, t.type, t.recurringId ?? NSNull()])
        return lastInsertRowId()
    }

    func updateTransaction(_ t: Transaction) {
        exec("UPDATE transactions SET amount=?, description=?, category_id=?, date=?, type=? WHERE id=?",
             [t.amount, t.description, t.categoryId ?? NSNull(), t.date, t.type, t.id])
    }

    func deleteTransaction(_ id: Int64) {
        exec("DELETE FROM transactions WHERE id=?", [id])
    }

    // MARK: - Recurring

    func getAllRecurring() -> [RecurringTransaction] {
        let rows = queryRows("SELECT id, amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active FROM recurring_transactions ORDER BY next_due_date")
        return rows.map { r in
            RecurringTransaction(id: r[0] as! Int64, amount: r[1] as! Double, description: r[2] as! String,
                                 categoryId: r[3] as? Int64, type: r[4] as! String, frequency: r[5] as! String,
                                 startDate: r[6] as! String, endDate: r[7] as? String,
                                 nextDueDate: r[8] as! String, active: (r[9] as! Int64) == 1)
        }
    }

    func getActiveRecurring() -> [RecurringTransaction] {
        let rows = queryRows("SELECT id, amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active FROM recurring_transactions WHERE active = 1 ORDER BY next_due_date")
        return rows.map { r in
            RecurringTransaction(id: r[0] as! Int64, amount: r[1] as! Double, description: r[2] as! String,
                                 categoryId: r[3] as? Int64, type: r[4] as! String, frequency: r[5] as! String,
                                 startDate: r[6] as! String, endDate: r[7] as? String,
                                 nextDueDate: r[8] as! String, active: (r[9] as! Int64) == 1)
        }
    }

    func getRecurringCount() -> Int {
        queryInt("SELECT COUNT(*) FROM recurring_transactions")
    }

    func addRecurring(_ r: RecurringTransaction) -> Int64 {
        exec("INSERT INTO recurring_transactions (amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
             [r.amount, r.description, r.categoryId ?? NSNull(), r.type, r.frequency, r.startDate, r.endDate ?? NSNull(), r.nextDueDate, r.active ? 1 : 0])
        return lastInsertRowId()
    }

    func updateRecurring(_ r: RecurringTransaction) {
        exec("UPDATE recurring_transactions SET amount=?, description=?, category_id=?, type=?, frequency=?, start_date=?, end_date=?, next_due_date=?, active=? WHERE id=?",
             [r.amount, r.description, r.categoryId ?? NSNull(), r.type, r.frequency, r.startDate, r.endDate ?? NSNull(), r.nextDueDate, r.active ? 1 : 0, r.id])
    }

    func deleteRecurring(_ id: Int64) {
        exec("DELETE FROM recurring_transactions WHERE id=?", [id])
    }

    // MARK: - Settings

    func getSetting(_ key: String) -> String? {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT value FROM app_settings WHERE key=?", -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        var result: String?
        if sqlite3_step(stmt) == SQLITE_ROW, let cStr = sqlite3_column_text(stmt, 0) {
            result = String(cString: cStr)
        }
        sqlite3_finalize(stmt)
        return result
    }

    func setSetting(_ key: String, _ value: String) {
        exec("INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)", [key, value])
    }

    // MARK: - Backup / Restore

    /// Produces the exact same SQL-dump format as the Expo app's `createBackup()`
    /// (see `src/utils/backup.ts`), so backups are interchangeable between both apps.
    func backupToSQL() -> String {
        let cats = getAllCategories()
        let txs = getAllTransactions()
        let recs = getAllRecurring()
        let theme = getSetting("theme") ?? "light"
        let monthlyBudget = getSetting("monthly_budget")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "6.0.0"

        func esc(_ s: String) -> String { "'" + s.replacingOccurrences(of: "'", with: "''") + "'" }
        func escOpt(_ s: String?) -> String { s.map(esc) ?? "NULL" }
        func escIntOpt(_ i: Int64?) -> String { i.map { "\($0)" } ?? "NULL" }

        var lines: [String] = []
        lines.append("-- FinanzApp Backup")
        lines.append("-- Generated: \(ISO8601DateFormatter().string(from: Date()))")
        lines.append("-- App Version: \(version)")
        lines.append("")

        if !cats.isEmpty {
            lines.append("--- Categories ---")
            for c in cats {
                lines.append("INSERT INTO categories (id, name, icon, color, type, is_default) VALUES (\(c.id), \(esc(c.name)), \(esc(c.icon)), \(esc(c.color)), \(esc(c.type)), \(c.isDefault ? 1 : 0));")
            }
            lines.append("")
        }

        if !txs.isEmpty {
            lines.append("--- Transactions ---")
            for t in txs {
                lines.append("INSERT INTO transactions (id, amount, description, category_id, date, type, recurring_id) VALUES (\(t.id), \(t.amount), \(esc(t.description)), \(escIntOpt(t.categoryId)), \(esc(t.date)), \(esc(t.type)), \(escIntOpt(t.recurringId)));")
            }
            lines.append("")
        }

        if !recs.isEmpty {
            lines.append("--- Recurring Transactions ---")
            for r in recs {
                lines.append("INSERT INTO recurring_transactions (id, amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active) VALUES (\(r.id), \(r.amount), \(esc(r.description)), \(escIntOpt(r.categoryId)), \(esc(r.type)), \(esc(r.frequency)), \(esc(r.startDate)), \(escOpt(r.endDate)), \(esc(r.nextDueDate)), \(r.active ? 1 : 0));")
            }
            lines.append("")
        }

        lines.append("--- Settings ---")
        lines.append("INSERT INTO app_settings (key, value) VALUES ('theme', \(esc(theme)));")
        if let monthlyBudget {
            lines.append("INSERT INTO app_settings (key, value) VALUES ('monthly_budget', \(esc(monthlyBudget)));")
        }
        lines.append("")

        let deleteStmts = "DELETE FROM transactions;\nDELETE FROM recurring_transactions;\nDELETE FROM categories;\nDELETE FROM app_settings;\n\n"
        return "PRAGMA foreign_keys=OFF;\nBEGIN TRANSACTION;\n\n\(deleteStmts)\(lines.joined(separator: "\n"))COMMIT;\nPRAGMA foreign_keys=ON;\n"
    }

    /// Restores a backup. Supports both the SQL-dump format shared with the Expo app (executed
    /// as-is — any column an INSERT statement omits, e.g. a field a backup predates, just falls
    /// back to the schema's own default) and the older JSON format some earlier native builds
    /// produced, kept here for backwards compatibility.
    func restoreFromBackup(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{") {
            return restoreFromJSON(content)
        }
        guard trimmed.hasPrefix("PRAGMA") || trimmed.hasPrefix("--") || trimmed.contains("INSERT INTO") else { return false }
        return execScript(content)
    }

    private func restoreFromJSON(_ json: String) -> Bool {
        guard let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return false }

        let cats = dict["categories"] as? [[String: Any]] ?? []
        let txs = dict["transactions"] as? [[String: Any]] ?? []
        let recs = dict["recurring"] as? [[String: Any]] ?? []
        let theme = dict["theme"] as? String ?? "light"

        exec("DELETE FROM transactions")
        exec("DELETE FROM recurring_transactions")
        exec("DELETE FROM categories")
        exec("DELETE FROM app_settings")

        for cat in cats {
            guard let name = cat["name"] as? String, !name.isEmpty else { continue }
            let icon = cat["icon"] as? String ?? "tag"
            let color = cat["color"] as? String ?? "#757575"
            let type = cat["type"] as? String ?? "expense"
            let isDefault = (cat["is_default"] as? Int ?? 0) == 1
            exec("INSERT INTO categories (name, icon, color, type, is_default) VALUES (?, ?, ?, ?, ?)",
                 [name, icon, color, type, isDefault ? 1 : 0])
        }

        for tx in txs {
            guard let amount = tx["amount"] as? Double, amount > 0 else { continue }
            let desc = tx["description"] as? String ?? ""
            let date = tx["date"] as? String ?? Date.currentString
            let type = tx["type"] as? String ?? "expense"
            let catId = tx["category_id"] as? Int64
            let recId = tx["recurring_id"] as? Int64
            let newCatId = remappedCategoryId(catId: catId, categories: cats)
            exec("INSERT INTO transactions (amount, description, category_id, date, type, recurring_id) VALUES (?, ?, ?, ?, ?, ?)",
                 [amount, desc, newCatId ?? NSNull(), date, type, recId ?? NSNull()])
        }

        for rec in recs {
            guard let amount = rec["amount"] as? Double, amount > 0 else { continue }
            let desc = rec["description"] as? String ?? ""
            let type = rec["type"] as? String ?? "expense"
            let freq = rec["frequency"] as? String ?? "monthly"
            let startDate = rec["start_date"] as? String ?? Date.currentString
            let nextDue = rec["next_due_date"] as? String ?? Date.currentString
            let catId = rec["category_id"] as? Int64
            let endDate = rec["end_date"] as? String
            let active = (rec["active"] as? Int ?? 1) == 1
            let newCatId = remappedCategoryId(catId: catId, categories: cats)
            exec("INSERT INTO recurring_transactions (amount, description, category_id, type, frequency, start_date, end_date, next_due_date, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                 [amount, desc, newCatId ?? NSNull(), type, freq, startDate, endDate ?? NSNull(), nextDue, active ? 1 : 0])
        }

        setSetting("theme", theme)
        if let monthlyBudget = dict["monthly_budget"] as? String {
            setSetting("monthly_budget", monthlyBudget)
        } else if let monthlyBudget = dict["monthly_budget"] as? Double {
            setSetting("monthly_budget", String(monthlyBudget))
        }
        return true
    }

    private func remappedCategoryId(catId: Int64?, categories: [[String: Any]]) -> Int64? {
        guard let catId else { return nil }
        guard let oldCat = categories.first(where: { ($0["id"] as? Int64) == catId }),
              let name = oldCat["name"] as? String else { return nil }
        let rows = queryRows("SELECT id FROM categories WHERE name = ?", [name])
        return rows.first?.first as? Int64
    }

    private func escaped(_ str: String) -> String {
        str.replacingOccurrences(of: "\\", with: "\\\\")
           .replacingOccurrences(of: "\"", with: "\\\"")
           .replacingOccurrences(of: "\n", with: "\\n")
           .replacingOccurrences(of: "\r", with: "\\r")
           .replacingOccurrences(of: "\t", with: "\\t")
    }

}