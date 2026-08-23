import AppIntents
import WidgetKit
import Foundation

/// A category, exposed to the Shortcuts/App Intents system so `QuickAddTransactionIntent` can
/// offer a picker over the user's real categories. The transaction's expense/income `type` is
/// derived from the chosen category's own type, so the intent doesn't need a separate,
/// possibly-inconsistent "type" parameter.
struct CategoryEntity: AppEntity {
    let id: Int64
    let name: String
    let type: String
    let colorHex: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Categoria")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(type == "income" ? L.income : L.expense)")
    }

    static var defaultQuery = CategoryEntityQuery()
}

struct CategoryEntityQuery: EntityQuery {
    func entities(for identifiers: [Int64]) async throws -> [CategoryEntity] {
        DatabaseManager.shared.getAllCategories()
            .filter { identifiers.contains($0.id) }
            .map { CategoryEntity(id: $0.id, name: $0.name, type: $0.type, colorHex: $0.color) }
    }

    func suggestedEntities() async throws -> [CategoryEntity] {
        DatabaseManager.shared.getAllCategories()
            .map { CategoryEntity(id: $0.id, name: $0.name, type: $0.type, colorHex: $0.color) }
    }
}

/// Assignable from *Impostazioni → Accessibilità → Tocco → Tocco successivo* (Back Tap) once
/// exposed via `FinanzAppShortcuts` below — no separate Shortcut needs to be hand-built first.
/// Runs in the app's own process without opening its UI (`openAppWhenRun = false`); iOS shows
/// its own compact system prompt for whichever parameters aren't pre-filled.
struct QuickAddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Aggiungi transazione rapida"
    static var description = IntentDescription("Registra rapidamente una spesa o un'entrata in FinanzApp.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Importo")
    var amount: Double

    @Parameter(title: "Categoria")
    var category: CategoryEntity

    @Parameter(title: "Nota")
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Aggiungi \(\.$amount) a \(\.$category)") {
            \.$note
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let db = DatabaseManager.shared
        let tx = Transaction(amount: amount, description: note ?? "", categoryId: category.id, date: Date.currentString, type: category.type, recurringId: nil)
        _ = db.addTransaction(tx)
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: IntentDialog(stringLiteral: L.quickAddConfirmation(amount: formatCurrency(amount), category: category.name)))
    }
}

struct FinanzAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickAddTransactionIntent(),
            phrases: [
                "Aggiungi una spesa a \(.applicationName)",
                "Registra una transazione su \(.applicationName)",
                "Aggiunta rapida \(.applicationName)"
            ],
            shortTitle: "Aggiungi rapido",
            systemImageName: "plus.circle.fill"
        )
    }
}
