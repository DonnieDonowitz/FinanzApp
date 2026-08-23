import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case it, en, de, fr, es
    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .it: return "it_IT"
        case .en: return "en_US"
        case .de: return "de_DE"
        case .fr: return "fr_FR"
        case .es: return "es_ES"
        }
    }

    var nativeName: String {
        switch self {
        case .it: return "Italiano"
        case .en: return "English"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .es: return "Español"
        }
    }
}

struct CurrencyOption: Identifiable, Hashable {
    let code: String
    let symbol: String
    var id: String { code }
}

let SUPPORTED_CURRENCIES: [CurrencyOption] = [
    CurrencyOption(code: "EUR", symbol: "€"),
    CurrencyOption(code: "USD", symbol: "$"),
    CurrencyOption(code: "GBP", symbol: "£"),
    CurrencyOption(code: "CHF", symbol: "CHF"),
    CurrencyOption(code: "JPY", symbol: "¥"),
]

/// Settings shared with the widget extension via the app group container, so both the app
/// and the widget agree on currency/language without the widget needing its own UI for them.
let sharedSettingsDefaults = UserDefaults(suiteName: "group.com.finanzapp.app") ?? .standard

enum AppSettingsStore {
    /// Falls back to the device's system language on first launch (before the user picks one
    /// explicitly), and to English if the system language isn't one of the supported ones.
    static var languageCode: String {
        if let saved = sharedSettingsDefaults.string(forKey: "languageCode") { return saved }
        let systemCode = Locale.current.language.languageCode?.identifier ?? "en"
        return AppLanguage(rawValue: systemCode) != nil ? systemCode : "en"
    }
    static var currentLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .en
    }
    static var currencyCode: String {
        sharedSettingsDefaults.string(forKey: "currencyCode") ?? "EUR"
    }
    static var currentCurrencySymbol: String {
        SUPPORTED_CURRENCIES.first(where: { $0.code == currencyCode })?.symbol ?? "€"
    }
}

/// Lightweight in-app localization, independent of system language, switchable at runtime.
enum L {
    private static var lang: AppLanguage { AppSettingsStore.currentLanguage }

    private static func t(it: String, en: String, de: String, fr: String, es: String) -> String {
        switch lang {
        case .it: return it
        case .en: return en
        case .de: return de
        case .fr: return fr
        case .es: return es
        }
    }

    // MARK: - Tab bar
    static var tabHome: String { t(it: "Home", en: "Home", de: "Start", fr: "Accueil", es: "Inicio") }
    static var tabMovements: String { t(it: "Movimenti", en: "Transactions", de: "Bewegungen", fr: "Mouvements", es: "Movimientos") }
    static var tabRecurring: String { t(it: "Ricorrenti", en: "Recurring", de: "Wiederkehrend", fr: "Récurrents", es: "Recurrentes") }
    static var tabSettings: String { t(it: "Impostazioni", en: "Settings", de: "Einstellungen", fr: "Réglages", es: "Ajustes") }

    // MARK: - Common
    static var save: String { t(it: "Salva", en: "Save", de: "Speichern", fr: "Enregistrer", es: "Guardar") }
    static var cancel: String { t(it: "Annulla", en: "Cancel", de: "Abbrechen", fr: "Annuler", es: "Cancelar") }
    static var close: String { t(it: "Chiudi", en: "Close", de: "Schließen", fr: "Fermer", es: "Cerrar") }
    static var ok: String { t(it: "OK", en: "OK", de: "OK", fr: "OK", es: "OK") }
    static var delete: String { t(it: "Elimina", en: "Delete", de: "Löschen", fr: "Supprimer", es: "Eliminar") }
    static var deleteTransactionSwipeLabel: String { t(it: "Elimina transazione", en: "Delete transaction", de: "Transaktion löschen", fr: "Supprimer la transaction", es: "Eliminar transacción") }
    static var deleteTransactionConfirmTitle: String { t(it: "Eliminare la transazione?", en: "Delete transaction?", de: "Transaktion löschen?", fr: "Supprimer la transaction ?", es: "¿Eliminar transacción?") }
    static var deleteTransactionConfirmMessage: String { t(it: "Questa transazione verrà eliminata definitivamente.", en: "This transaction will be permanently deleted.", de: "Diese Transaktion wird endgültig gelöscht.", fr: "Cette transaction sera définitivement supprimée.", es: "Esta transacción se eliminará permanentemente.") }
    static var deleteRecurringSwipeLabel: String { t(it: "Elimina ricorrenza", en: "Delete recurring item", de: "Wiederkehrenden Eintrag löschen", fr: "Supprimer l'élément récurrent", es: "Eliminar elemento recurrente") }
    static var deleteRecurringConfirmTitle: String { t(it: "Eliminare la ricorrenza?", en: "Delete recurring item?", de: "Wiederkehrenden Eintrag löschen?", fr: "Supprimer l'élément récurrent ?", es: "¿Eliminar elemento recurrente?") }
    static var deleteRecurringConfirmMessage: String { t(it: "Questa transazione ricorrente verrà eliminata definitivamente.", en: "This recurring item will be permanently deleted.", de: "Dieser wiederkehrende Eintrag wird endgültig gelöscht.", fr: "Cet élément récurrent sera définitivement supprimé.", es: "Este elemento recurrente se eliminará permanentemente.") }
    static var add: String { t(it: "Aggiungi", en: "Add", de: "Hinzufügen", fr: "Ajouter", es: "Añadir") }
    static var today: String { t(it: "Oggi", en: "Today", de: "Heute", fr: "Aujourd'hui", es: "Hoy") }
    static var yesterday: String { t(it: "Ieri", en: "Yesterday", de: "Gestern", fr: "Hier", es: "Ayer") }
    static var income: String { t(it: "Entrata", en: "Income", de: "Einnahme", fr: "Entrée", es: "Ingreso") }
    static var expense: String { t(it: "Uscita", en: "Expense", de: "Ausgabe", fr: "Sortie", es: "Gasto") }
    static var incomes: String { t(it: "Entrate", en: "Income", de: "Einnahmen", fr: "Entrées", es: "Ingresos") }
    static var expenses: String { t(it: "Uscite", en: "Expenses", de: "Ausgaben", fr: "Sorties", es: "Gastos") }
    static var all: String { t(it: "Tutti", en: "All", de: "Alle", fr: "Tous", es: "Todos") }
    static var category: String { t(it: "Categoria", en: "Category", de: "Kategorie", fr: "Catégorie", es: "Categoría") }
    static var seeAll: String { t(it: "Vedi tutte", en: "See all", de: "Alle anzeigen", fr: "Tout voir", es: "Ver todo") }
    static var month: String { t(it: "Mese", en: "Month", de: "Monat", fr: "Mois", es: "Mes") }

    // MARK: - Home
    static func greeting(hour: Int) -> String {
        if hour < 12 { return t(it: "Buongiorno, Marino", en: "Good morning, Marino", de: "Guten Morgen, Marino", fr: "Bonjour, Marino", es: "Buenos días, Marino") }
        else if hour < 18 { return t(it: "Buon pomeriggio, Marino", en: "Good afternoon, Marino", de: "Guten Tag, Marino", fr: "Bon après-midi, Marino", es: "Buenas tardes, Marino") }
        else { return t(it: "Buonasera, Marino", en: "Good evening, Marino", de: "Guten Abend, Marino", fr: "Bonsoir, Marino", es: "Buenas noches, Marino") }
    }
    static var overview: String { t(it: "Panoramica", en: "Overview", de: "Übersicht", fr: "Aperçu", es: "Resumen") }
    static var totalBalance: String { t(it: "SALDO TOTALE", en: "TOTAL BALANCE", de: "GESAMTSALDO", fr: "SOLDE TOTAL", es: "SALDO TOTAL") }
    static var newExpense: String { t(it: "Nuova Uscita", en: "New Expense", de: "Neue Ausgabe", fr: "Nouvelle sortie", es: "Nuevo gasto") }
    static var newIncome: String { t(it: "Nuova Entrata", en: "New Income", de: "Neue Einnahme", fr: "Nouvelle entrée", es: "Nuevo ingreso") }
    static var dailyAverage: String { t(it: "MEDIA GIORNALIERA", en: "DAILY AVERAGE", de: "TÄGLICHER DURCHSCHNITT", fr: "MOYENNE QUOTIDIENNE", es: "PROMEDIO DIARIO") }
    static var expenseRatio: String { t(it: "RAPPORTO SPESE", en: "EXPENSE RATIO", de: "AUSGABENQUOTE", fr: "RATIO DE DÉPENSES", es: "RATIO DE GASTOS") }
    static var topCategories: String { t(it: "Categorie principali", en: "Top categories", de: "Top-Kategorien", fr: "Catégories principales", es: "Categorías principales") }
    static var recentTransactions: String { t(it: "Transazioni recenti", en: "Recent transactions", de: "Letzte Bewegungen", fr: "Transactions récentes", es: "Transacciones recientes") }

    // MARK: - Movimenti
    static var movements: String { t(it: "Movimenti", en: "Transactions", de: "Bewegungen", fr: "Mouvements", es: "Movimientos") }
    static var statistics: String { t(it: "Statistiche", en: "Statistics", de: "Statistiken", fr: "Statistiques", es: "Estadísticas") }
    static var noMovements: String { t(it: "Nessun movimento", en: "No transactions", de: "Keine Bewegungen", fr: "Aucun mouvement", es: "Sin movimientos") }

    // MARK: - Add Transaction
    static var newMovement: String { t(it: "Nuovo Movimento", en: "New Transaction", de: "Neue Bewegung", fr: "Nouveau mouvement", es: "Nuevo movimiento") }
    static var editMovement: String { t(it: "Modifica Movimento", en: "Edit Transaction", de: "Bewegung bearbeiten", fr: "Modifier le mouvement", es: "Editar movimiento") }
    static var amount: String { t(it: "IMPORTO", en: "AMOUNT", de: "BETRAG", fr: "MONTANT", es: "IMPORTE") }
    static var type: String { t(it: "TIPO", en: "TYPE", de: "TYP", fr: "TYPE", es: "TIPO") }
    static var description: String { t(it: "DESCRIZIONE", en: "DESCRIPTION", de: "BESCHREIBUNG", fr: "DESCRIPTION", es: "DESCRIPCIÓN") }
    static var descriptionPlaceholder: String { t(it: "Es. Spesa al supermercato", en: "E.g. Grocery shopping", de: "Z.B. Einkauf im Supermarkt", fr: "Ex. Courses au supermarché", es: "Ej. Compra en el supermercado") }
    static var categoryLabel: String { t(it: "CATEGORIA", en: "CATEGORY", de: "KATEGORIE", fr: "CATÉGORIE", es: "CATEGORÍA") }
    static var selectCategory: String { t(it: "Seleziona categoria", en: "Select category", de: "Kategorie wählen", fr: "Choisir une catégorie", es: "Seleccionar categoría") }
    static var date: String { t(it: "DATA", en: "DATE", de: "DATUM", fr: "DATE", es: "FECHA") }

    // MARK: - Recurring
    static var recurring: String { t(it: "Ricorrenti", en: "Recurring", de: "Wiederkehrend", fr: "Récurrents", es: "Recurrentes") }
    static var recurringSubtitle: String { t(it: "Abbonamenti e pagamenti fissi", en: "Subscriptions and fixed payments", de: "Abos und feste Zahlungen", fr: "Abonnements et paiements fixes", es: "Suscripciones y pagos fijos") }
    static var totalPerMonth: String { t(it: "TOTALE / MESE", en: "TOTAL / MONTH", de: "GESAMT / MONAT", fr: "TOTAL / MOIS", es: "TOTAL / MES") }
    static var active: String { t(it: "ATTIVE", en: "ACTIVE", de: "AKTIV", fr: "ACTIFS", es: "ACTIVOS") }
    static var next: String { t(it: "PROSSIMA", en: "NEXT", de: "NÄCHSTE", fr: "PROCHAIN", es: "PRÓXIMO") }
    static var upcoming: String { t(it: "In scadenza", en: "Upcoming", de: "Anstehend", fr: "À venir", es: "Próximos") }
    static var calendar: String { t(it: "Calendario", en: "Calendar", de: "Kalender", fr: "Calendrier", es: "Calendario") }
    static var noRecurring: String { t(it: "Nessuna ricorrente", en: "No recurring items", de: "Keine wiederkehrenden Posten", fr: "Aucun élément récurrent", es: "Sin elementos recurrentes") }
    static var newRecurring: String { t(it: "Nuova Ricorrente", en: "New Recurring", de: "Neu wiederkehrend", fr: "Nouveau récurrent", es: "Nuevo recurrente") }
    static var frequency: String { t(it: "FREQUENZA", en: "FREQUENCY", de: "HÄUFIGKEIT", fr: "FRÉQUENCE", es: "FRECUENCIA") }
    static var daily: String { t(it: "Giornaliero", en: "Daily", de: "Täglich", fr: "Quotidien", es: "Diario") }
    static var weekly: String { t(it: "Settimanale", en: "Weekly", de: "Wöchentlich", fr: "Hebdomadaire", es: "Semanal") }
    static var monthly: String { t(it: "Mensile", en: "Monthly", de: "Monatlich", fr: "Mensuel", es: "Mensual") }
    static var yearly: String { t(it: "Annuale", en: "Yearly", de: "Jährlich", fr: "Annuel", es: "Anual") }
    static var nextPaymentDate: String { t(it: "DATA PROSSIMO PAGAMENTO", en: "NEXT PAYMENT DATE", de: "NÄCHSTES ZAHLUNGSDATUM", fr: "DATE DU PROCHAIN PAIEMENT", es: "FECHA DEL PRÓXIMO PAGO") }
    static var recurringDescPlaceholder: String { t(it: "Es. Abbonamento Netflix", en: "E.g. Netflix subscription", de: "Z.B. Netflix-Abo", fr: "Ex. Abonnement Netflix", es: "Ej. Suscripción Netflix") }

    // MARK: - Statistics
    static var monthlyAnalysis: String { t(it: "Analisi mensile", en: "Monthly analysis", de: "Monatsanalyse", fr: "Analyse mensuelle", es: "Análisis mensual") }
    static var weeklyAnalysis: String { t(it: "Analisi settimanale", en: "Weekly analysis", de: "Wochenanalyse", fr: "Analyse hebdomadaire", es: "Análisis semanal") }
    static var annualAnalysis: String { t(it: "Analisi annuale", en: "Annual analysis", de: "Jahresanalyse", fr: "Analyse annuelle", es: "Análisis anual") }
    static var week: String { t(it: "Settimana", en: "Week", de: "Woche", fr: "Semaine", es: "Semana") }
    static var year: String { t(it: "Anno", en: "Year", de: "Jahr", fr: "Année", es: "Año") }
    static var netSavings: String { t(it: "RISPARMIO NETTO", en: "NET SAVINGS", de: "NETTOERSPARNIS", fr: "ÉPARGNE NETTE", es: "AHORRO NETO") }
    static var vsPreviousPeriod: String { t(it: "rispetto a periodo prec.", en: "vs previous period", de: "im Vergleich zum Vorzeitraum", fr: "vs période précédente", es: "vs período anterior") }
    static var expensesByCategory: String { t(it: "Uscite per categoria", en: "Expenses by category", de: "Ausgaben nach Kategorie", fr: "Dépenses par catégorie", es: "Gastos por categoría") }
    static var expenseRatioTrend: String { t(it: "Andamento rapporto spese", en: "Expense ratio trend", de: "Entwicklung der Ausgabenquote", fr: "Évolution du ratio de dépenses", es: "Tendencia del ratio de gastos") }

    // MARK: - Annual summary
    static var annualSummary: String { t(it: "Riepilogo Annuale", en: "Annual Summary", de: "Jahresübersicht", fr: "Bilan annuel", es: "Resumen anual") }
    static var annualBalance: String { t(it: "Saldo Annuale", en: "Annual Balance", de: "Jahressaldo", fr: "Solde annuel", es: "Saldo anual") }
    static var balance: String { t(it: "Saldo", en: "Balance", de: "Saldo", fr: "Solde", es: "Saldo") }

    // MARK: - Settings
    static var settings: String { t(it: "Impostazioni", en: "Settings", de: "Einstellungen", fr: "Réglages", es: "Ajustes") }
    static var appearance: String { t(it: "ASPETTO", en: "APPEARANCE", de: "DARSTELLUNG", fr: "APPARENCE", es: "APARIENCIA") }
    static var darkTheme: String { t(it: "Tema Scuro", en: "Dark Theme", de: "Dunkles Design", fr: "Thème sombre", es: "Tema oscuro") }
    static var reminder: String { t(it: "PROMEMORIA", en: "REMINDER", de: "ERINNERUNG", fr: "RAPPEL", es: "RECORDATORIO") }
    static var dailyReminder: String { t(it: "Promemoria giornaliero", en: "Daily reminder", de: "Tägliche Erinnerung", fr: "Rappel quotidien", es: "Recordatorio diario") }
    static var reminderHint: String { t(it: "Ricevi una notifica ogni giorno per non dimenticare di registrare le spese.", en: "Get a notification every day so you don't forget to log your expenses.", de: "Erhalte täglich eine Benachrichtigung, damit du deine Ausgaben nicht vergisst.", fr: "Recevez une notification chaque jour pour ne pas oublier d'enregistrer vos dépenses.", es: "Recibe una notificación cada día para no olvidar registrar tus gastos.") }
    static var reminderNotificationTitle: String { t(it: "FinanzApp", en: "FinanzApp", de: "FinanzApp", fr: "FinanzApp", es: "FinanzApp") }
    static var reminderNotificationBody: String { t(it: "Ricordati di inserire le spese di oggi!", en: "Don't forget to log today's expenses!", de: "Vergiss nicht, deine heutigen Ausgaben einzutragen!", fr: "N'oubliez pas d'enregistrer vos dépenses d'aujourd'hui !", es: "¡No olvides registrar los gastos de hoy!") }
    static var time: String { t(it: "Orario", en: "Time", de: "Uhrzeit", fr: "Heure", es: "Hora") }
    static var management: String { t(it: "GESTIONE", en: "MANAGEMENT", de: "VERWALTUNG", fr: "GESTION", es: "GESTIÓN") }
    static var categories: String { t(it: "Categorie", en: "Categories", de: "Kategorien", fr: "Catégories", es: "Categorías") }
    static var backup: String { t(it: "BACKUP", en: "BACKUP", de: "SICHERUNG", fr: "SAUVEGARDE", es: "COPIA DE SEGURIDAD") }
    static var createBackup: String { t(it: "Crea Backup", en: "Create Backup", de: "Sicherung erstellen", fr: "Créer une sauvegarde", es: "Crear copia de seguridad") }
    static var restoreBackup: String { t(it: "Ripristina Backup", en: "Restore Backup", de: "Sicherung wiederherstellen", fr: "Restaurer la sauvegarde", es: "Restaurar copia de seguridad") }
    static var backupHint: String { t(it: "I backup hanno estensione .finanz e contengono categorie, transazioni, ricorrenti e impostazioni.", en: "Backups use the .finanz extension and contain categories, transactions, recurring items and settings.", de: "Sicherungen haben die Endung .finanz und enthalten Kategorien, Transaktionen, wiederkehrende Posten und Einstellungen.", fr: "Les sauvegardes ont l'extension .finanz et contiennent les catégories, transactions, éléments récurrents et réglages.", es: "Las copias de seguridad tienen la extensión .finanz y contienen categorías, transacciones, elementos recurrentes y ajustes.") }
    static var autoBackupSection: String { t(it: "BACKUP AUTOMATICO", en: "AUTOMATIC BACKUP", de: "AUTOMATISCHE SICHERUNG", fr: "SAUVEGARDE AUTOMATIQUE", es: "COPIA DE SEGURIDAD AUTOMÁTICA") }
    static var autoBackup: String { t(it: "Backup automatico", en: "Automatic backup", de: "Automatische Sicherung", fr: "Sauvegarde automatique", es: "Copia de seguridad automática") }
    static var autoBackupHint: String { t(it: "I backup automatici vengono salvati sul dispositivo nella cartella FinanzApp dell'app File, con la frequenza scelta.", en: "Automatic backups are saved on your device in the FinanzApp folder in the Files app, at the frequency you choose.", de: "Automatische Sicherungen werden mit der gewählten Häufigkeit im Ordner FinanzApp der Dateien-App auf deinem Gerät gespeichert.", fr: "Les sauvegardes automatiques sont enregistrées sur l'appareil dans le dossier FinanzApp de l'app Fichiers, selon la fréquence choisie.", es: "Las copias de seguridad automáticas se guardan en el dispositivo en la carpeta FinanzApp de la app Archivos, con la frecuencia elegida.") }
    static var backupFrequency: String { t(it: "Frequenza", en: "Frequency", de: "Häufigkeit", fr: "Fréquence", es: "Frecuencia") }
    static var backupFolder: String { t(it: "Cartella", en: "Folder", de: "Ordner", fr: "Dossier", es: "Carpeta") }
    static var chooseFolder: String { t(it: "Scegli cartella…", en: "Choose folder…", de: "Ordner wählen…", fr: "Choisir un dossier…", es: "Elegir carpeta…") }
    static var backupFolderDefault: String { t(it: "Predefinita (app)", en: "Default (app)", de: "Standard (App)", fr: "Par défaut (app)", es: "Predeterminada (app)") }
    static var backupFolderHint: String { t(it: "Scegli una cartella (es. iCloud Drive) perché i backup automatici non vengano persi se l'app viene reinstallata.", en: "Choose a folder (e.g. iCloud Drive) so automatic backups aren't lost if the app gets reinstalled.", de: "Wähle einen Ordner (z. B. iCloud Drive), damit automatische Sicherungen bei einer Neuinstallation der App nicht verloren gehen.", fr: "Choisissez un dossier (p. ex. iCloud Drive) pour que les sauvegardes automatiques ne soient pas perdues si l'app est réinstallée.", es: "Elige una carpeta (p. ej. iCloud Drive) para que las copias de seguridad automáticas no se pierdan si la app se reinstala.") }
    static var restoreConfirmTitle: String { t(it: "Ripristina Backup", en: "Restore Backup", de: "Sicherung wiederherstellen", fr: "Restaurer la sauvegarde", es: "Restaurar copia de seguridad") }
    static var restoreConfirmMessage: String { t(it: "Tutti i dati correnti verranno sostituiti con quelli del backup. Continuare?", en: "All current data will be replaced with the backup's data. Continue?", de: "Alle aktuellen Daten werden durch die Sicherung ersetzt. Fortfahren?", fr: "Toutes les données actuelles seront remplacées par celles de la sauvegarde. Continuer ?", es: "Todos los datos actuales se sustituirán por los de la copia de seguridad. ¿Continuar?") }
    static var info: String { t(it: "INFO", en: "INFO", de: "INFO", fr: "INFOS", es: "INFO") }
    static var version: String { t(it: "Versione", en: "Version", de: "Version", fr: "Version", es: "Versión") }
    static var region: String { t(it: "REGIONE", en: "REGION", de: "REGION", fr: "RÉGION", es: "REGIÓN") }
    static var language: String { t(it: "Lingua", en: "Language", de: "Sprache", fr: "Langue", es: "Idioma") }
    static var currency: String { t(it: "Valuta", en: "Currency", de: "Währung", fr: "Devise", es: "Moneda") }
    static var notificationsDisabledTitle: String { t(it: "Notifiche disattivate", en: "Notifications disabled", de: "Benachrichtigungen deaktiviert", fr: "Notifications désactivées", es: "Notificaciones desactivadas") }
    static var notificationsDisabledMessage: String { t(it: "Per ricevere il promemoria giornaliero, abilita le notifiche per FinanzApp nelle Impostazioni di sistema.", en: "To receive the daily reminder, enable notifications for FinanzApp in the system Settings.", de: "Um die tägliche Erinnerung zu erhalten, aktiviere Benachrichtigungen für FinanzApp in den Systemeinstellungen.", fr: "Pour recevoir le rappel quotidien, activez les notifications pour FinanzApp dans les réglages système.", es: "Para recibir el recordatorio diario, activa las notificaciones de FinanzApp en los ajustes del sistema.") }
    static var openSettings: String { t(it: "Apri Impostazioni", en: "Open Settings", de: "Einstellungen öffnen", fr: "Ouvrir les réglages", es: "Abrir ajustes") }

    // MARK: - Backup messages
    static var fileOpenError: String { t(it: "Impossibile aprire il file", en: "Unable to open the file", de: "Datei konnte nicht geöffnet werden", fr: "Impossible d'ouvrir le fichier", es: "No se pudo abrir el archivo") }
    static var backupCreateError: String { t(it: "Impossibile creare il backup", en: "Unable to create the backup", de: "Sicherung konnte nicht erstellt werden", fr: "Impossible de créer la sauvegarde", es: "No se pudo crear la copia de seguridad") }
    static var backupReadError: String { t(it: "Impossibile leggere il file di backup", en: "Unable to read the backup file", de: "Sicherungsdatei konnte nicht gelesen werden", fr: "Impossible de lire le fichier de sauvegarde", es: "No se pudo leer el archivo de copia de seguridad") }
    static var backupRestoreSuccess: String { t(it: "Backup ripristinato con successo.", en: "Backup restored successfully.", de: "Sicherung erfolgreich wiederhergestellt.", fr: "Sauvegarde restaurée avec succès.", es: "Copia de seguridad restaurada con éxito.") }
    static var backupRestoreError: String { t(it: "Impossibile ripristinare il backup.", en: "Unable to restore the backup.", de: "Sicherung konnte nicht wiederhergestellt werden.", fr: "Impossible de restaurer la sauvegarde.", es: "No se pudo restaurar la copia de seguridad.") }

    // MARK: - Expense alerts
    static var expenseAlerts: String { t(it: "AVVISI SPESE", en: "SPENDING ALERTS", de: "AUSGABENWARNUNGEN", fr: "ALERTES DE DÉPENSES", es: "ALERTAS DE GASTO") }
    static var expenseAlertsToggle: String { t(it: "Avvisami quando supero una soglia", en: "Alert me when I cross a threshold", de: "Benachrichtige mich bei Schwellenüberschreitung", fr: "M'alerter en cas de dépassement de seuil", es: "Avisarme al superar un umbral") }
    static var expenseAlertsHint: String { t(it: "Ricevi una notifica quando le tue spese del mese superano il 50%, 75%, 90% o 100% delle entrate.", en: "Get notified when this month's expenses exceed 50%, 75%, 90% or 100% of your income.", de: "Erhalte eine Benachrichtigung, wenn die Ausgaben dieses Monats 50 %, 75 %, 90 % oder 100 % deines Einkommens übersteigen.", fr: "Recevez une notification lorsque vos dépenses du mois dépassent 50 %, 75 %, 90 % ou 100 % de vos revenus.", es: "Recibe una notificación cuando los gastos de este mes superen el 50 %, 75 %, 90 % o 100 % de tus ingresos.") }
    static var expenseAlertTitle: String { t(it: "Attenzione alle spese", en: "Spending alert", de: "Ausgabenwarnung", fr: "Alerte dépenses", es: "Alerta de gastos") }
    static var addCustomThreshold: String { t(it: "Aggiungi soglia personalizzata", en: "Add custom threshold", de: "Eigenen Schwellenwert hinzufügen", fr: "Ajouter un seuil personnalisé", es: "Añadir umbral personalizado") }
    static var thresholdPlaceholder: String { t(it: "%", en: "%", de: "%", fr: "%", es: "%") }
    static func expenseAlertBody(percent: Int) -> String {
        t(it: "Stai spendendo abbastanza per questo mese! Ricorda di mettere da parte! Hai speso \(percent)% delle tue entrate mensili!",
          en: "You're spending quite a lot this month! Remember to set some money aside! You've spent \(percent)% of your monthly income!",
          de: "Du gibst diesen Monat ganz schön viel aus! Denk daran, etwas zurückzulegen! Du hast \(percent)% deines monatlichen Einkommens ausgegeben!",
          fr: "Vous dépensez pas mal ce mois-ci ! Pensez à mettre de l'argent de côté ! Vous avez dépensé \(percent)% de vos revenus mensuels !",
          es: "¡Estás gastando bastante este mes! ¡Recuerda apartar algo de dinero! ¡Has gastado el \(percent)% de tus ingresos mensuales!")
    }

    // MARK: - Category manager
    static var manageCategories: String { t(it: "Gestione Categorie", en: "Manage Categories", de: "Kategorien verwalten", fr: "Gérer les catégories", es: "Gestionar categorías") }
    static var newCategory: String { t(it: "Nuova Categoria", en: "New Category", de: "Neue Kategorie", fr: "Nouvelle catégorie", es: "Nueva categoría") }
    static var editCategory: String { t(it: "Modifica Categoria", en: "Edit Category", de: "Kategorie bearbeiten", fr: "Modifier la catégorie", es: "Editar categoría") }
    static var addCategory: String { t(it: "Aggiungi Categoria", en: "Add Category", de: "Kategorie hinzufügen", fr: "Ajouter une catégorie", es: "Añadir categoría") }
    static var name: String { t(it: "NOME", en: "NAME", de: "NAME", fr: "NOM", es: "NOMBRE") }
    static var categoryName: String { t(it: "Nome categoria", en: "Category name", de: "Kategoriename", fr: "Nom de la catégorie", es: "Nombre de categoría") }
    static var color: String { t(it: "COLORE", en: "COLOR", de: "FARBE", fr: "COULEUR", es: "COLOR") }
    static var icon: String { t(it: "ICONA", en: "ICON", de: "SYMBOL", fr: "ICÔNE", es: "ICONO") }
    static var iconPlaceholder: String { t(it: "Tocca e scegli un'emoji ⌨️", en: "Tap and pick an emoji ⌨️", de: "Tippen und Emoji wählen ⌨️", fr: "Touchez et choisissez un emoji ⌨️", es: "Toca y elige un emoji ⌨️") }
    static var iconHint: String { t(it: "Usa la tastiera emoji per scegliere un'icona personalizzata per questa categoria.", en: "Use the emoji keyboard to pick a custom icon for this category.", de: "Verwende die Emoji-Tastatur, um ein individuelles Symbol für diese Kategorie zu wählen.", fr: "Utilisez le clavier emoji pour choisir une icône personnalisée pour cette catégorie.", es: "Usa el teclado de emojis para elegir un icono personalizado para esta categoría.") }

    // MARK: - Default category names (built-in seeded categories only; user-created
    // categories keep whatever name the user typed).
    private static let categoryNames: [String: (en: String, de: String, fr: String, es: String)] = [
        "Alimentari": ("Groceries", "Lebensmittel", "Courses", "Alimentación"),
        "Trasporti": ("Transport", "Transport", "Transport", "Transporte"),
        "Abitazione": ("Housing", "Wohnen", "Logement", "Vivienda"),
        "Salute": ("Health", "Gesundheit", "Santé", "Salud"),
        "Intrattenimento": ("Entertainment", "Unterhaltung", "Divertissement", "Ocio"),
        "Abbigliamento": ("Clothing", "Kleidung", "Vêtements", "Ropa"),
        "Educazione": ("Education", "Bildung", "Éducation", "Educación"),
        "Ristoranti": ("Restaurants", "Restaurants", "Restaurants", "Restaurantes"),
        "Bollette": ("Bills", "Rechnungen", "Factures", "Facturas"),
        "Altro": ("Other", "Sonstiges", "Autre", "Otro"),
        "Stipendio": ("Salary", "Gehalt", "Salaire", "Salario"),
        "Freelance": ("Freelance", "Freiberuflich", "Freelance", "Autónomo"),
        "Investimenti": ("Investments", "Investitionen", "Investissements", "Inversiones"),
    ]

    /// Translates a built-in category's canonical (Italian) name for display in the current
    /// language. The underlying stored name never changes — it's just the display label.
    static func categoryName(_ name: String) -> String {
        guard let variants = categoryNames[name] else { return name }
        switch lang {
        case .it: return name
        case .en: return variants.en
        case .de: return variants.de
        case .fr: return variants.fr
        case .es: return variants.es
        }
    }

    // MARK: - Months
    static var monthsShort: [String] {
        switch lang {
        case .it: return IT_MONTHS_SHORT
        case .en: return ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        case .de: return ["Jan","Feb","Mär","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"]
        case .fr: return ["Jan","Fév","Mar","Avr","Mai","Juin","Juil","Août","Sep","Oct","Nov","Déc"]
        case .es: return ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"]
        }
    }

    // MARK: - Budget & Gamification
    static var monthlyBudget: String { t(it: "Budget mensile", en: "Monthly budget", de: "Monatsbudget", fr: "Budget mensuel", es: "Presupuesto mensual") }
    static var setBudgetPrompt: String { t(it: "Imposta un budget massimo di spesa mensile per iniziare a guadagnare livelli ed esperienza.", en: "Set a maximum monthly spending budget to start earning levels and XP.", de: "Lege ein monatliches Ausgabenlimit fest, um Level und XP zu sammeln.", fr: "Définis un budget de dépenses mensuel maximum pour commencer à gagner des niveaux et de l'XP.", es: "Establece un presupuesto máximo de gasto mensual para empezar a ganar niveles y XP.") }
    static var budgetExplanation: String { t(it: "Ogni euro risparmiato sotto il budget vale 5 punti esperienza. Ogni euro speso in più ne toglie 1. Se guadagni più del budget, ogni euro di entrate oltre il budget vale 1 punto esperienza extra.", en: "Every euro you save under budget is worth 5 XP. Every euro you overspend costs 1 XP. If you earn more than your budget, every euro of income above it is worth 1 extra XP.", de: "Jeder gesparte Euro unter dem Budget bringt 5 XP. Jeder Euro Mehrausgabe kostet 1 XP. Verdienst du mehr als dein Budget, bringt jeder Euro Einkommen darüber hinaus 1 zusätzlichen XP.", fr: "Chaque euro économisé sous le budget vaut 5 XP. Chaque euro dépensé en trop en coûte 1. Si tu gagnes plus que ton budget, chaque euro de revenu au-delà vaut 1 XP supplémentaire.", es: "Cada euro ahorrado por debajo del presupuesto vale 5 XP. Cada euro de más gastado cuesta 1 XP. Si ganas más que tu presupuesto, cada euro de ingresos por encima vale 1 XP extra.") }
    static func remainingBudget(_ amount: String) -> String {
        t(it: "\(amount) ancora disponibili questo mese", en: "\(amount) left this month", de: "\(amount) diesen Monat noch verfügbar", fr: "\(amount) encore disponibles ce mois-ci", es: "\(amount) disponibles este mes")
    }
    static func overBudgetBy(_ amount: String) -> String {
        t(it: "\(amount) oltre il budget", en: "\(amount) over budget", de: "\(amount) über dem Budget", fr: "\(amount) au-dessus du budget", es: "\(amount) por encima del presupuesto")
    }
    static func levelLabel(_ level: Int) -> String {
        t(it: "Livello \(level)", en: "Level \(level)", de: "Level \(level)", fr: "Niveau \(level)", es: "Nivel \(level)")
    }
    static func xpTotal(_ xp: Int) -> String {
        t(it: "\(xp) XP totali", en: "\(xp) total XP", de: "\(xp) XP insgesamt", fr: "\(xp) XP au total", es: "\(xp) XP totales")
    }
    static func xpEarnedThisMonth(_ xp: Int) -> String {
        t(it: "+\(xp) XP questo mese", en: "+\(xp) XP this month", de: "+\(xp) XP diesen Monat", fr: "+\(xp) XP ce mois-ci", es: "+\(xp) XP este mes")
    }
    static func xpLostThisMonth(_ xp: Int) -> String {
        t(it: "-\(xp) XP questo mese", en: "-\(xp) XP this month", de: "-\(xp) XP diesen Monat", fr: "-\(xp) XP ce mois-ci", es: "-\(xp) XP este mes")
    }
    static var levelUpTitle: String { t(it: "Livello raggiunto!", en: "Level up!", de: "Level aufgestiegen!", fr: "Niveau supérieur !", es: "¡Subiste de nivel!") }
    static func levelUpBody(level: Int) -> String {
        t(it: "Complimenti, hai raggiunto il livello \(level)!", en: "Congratulations, you reached level \(level)!", de: "Glückwunsch, du hast Level \(level) erreicht!", fr: "Félicitations, tu as atteint le niveau \(level) !", es: "¡Felicidades, alcanzaste el nivel \(level)!")
    }
    static var dailySpendingTrend: String { t(it: "Andamento giornaliero", en: "Daily trend", de: "Täglicher Verlauf", fr: "Tendance quotidienne", es: "Tendencia diaria") }
    static func dayTransactions(_ day: Int) -> String {
        t(it: "Spese del giorno \(day)", en: "Day \(day) transactions", de: "Transaktionen vom \(day).", fr: "Transactions du \(day)", es: "Transacciones del día \(day)")
    }
    static var noTransactionsThisDay: String { t(it: "Nessuna spesa in questo giorno.", en: "No transactions on this day.", de: "Keine Transaktionen an diesem Tag.", fr: "Aucune transaction ce jour-là.", es: "Sin transacciones este día.") }
    static var noExpensesThisMonth: String { t(it: "Nessuna spesa questo mese", en: "No expenses this month", de: "Keine Ausgaben diesen Monat", fr: "Aucune dépense ce mois-ci", es: "Sin gastos este mes") }
    static var advancedStatistics: String { t(it: "Statistiche avanzate", en: "Advanced statistics", de: "Erweiterte Statistiken", fr: "Statistiques avancées", es: "Estadísticas avanzadas") }
    static var semester: String { t(it: "Semestre", en: "Semester", de: "Halbjahr", fr: "Semestre", es: "Semestre") }
    static var firstHalf: String { t(it: "1° semestre", en: "1st half", de: "1. Halbjahr", fr: "1er semestre", es: "1er semestre") }
    static var secondHalf: String { t(it: "2° semestre", en: "2nd half", de: "2. Halbjahr", fr: "2e semestre", es: "2º semestre") }
    static var budgetLevelSection: String { t(it: "Budget & Livello", en: "Budget & Level", de: "Budget & Level", fr: "Budget et niveau", es: "Presupuesto y nivel") }
    static var backTapSection: String { t(it: "Aggiunta rapida (Tocco successivo)", en: "Quick add (Back Tap)", de: "Schnell hinzufügen (Rücktipp)", fr: "Ajout rapide (Toucher arrière)", es: "Añadir rápido (Toque trasero)") }
    static var backTapInstructions: String {
        t(it: "Per aggiungere una transazione con un doppio tocco sul retro dell'iPhone, vai in Impostazioni → Accessibilità → Tocco → Tocco successivo → Doppio tocco, e scegli l'azione \"Aggiungi rapido\" di FinanzApp.",
          en: "To add a transaction with a double tap on the back of your iPhone, go to Settings → Accessibility → Touch → Back Tap → Double Tap, and choose FinanzApp's \"Quick add\" action.",
          de: "Um eine Transaktion durch doppeltes Tippen auf die Rückseite deines iPhones hinzuzufügen, gehe zu Einstellungen → Bedienungshilfen → Tippen → Rücktipp → Doppeltippen und wähle die Aktion „Schnell hinzufügen“ von FinanzApp.",
          fr: "Pour ajouter une transaction en touchant deux fois l'arrière de ton iPhone, va dans Réglages → Accessibilité → Toucher → Toucher arrière → Double toucher, et choisis l'action « Ajout rapide » de FinanzApp.",
          es: "Para añadir una transacción con un doble toque en la parte trasera de tu iPhone, ve a Ajustes → Accesibilidad → Tocar → Toque trasero → Doble toque, y elige la acción \"Añadir rápido\" de FinanzApp.")
    }
    static func quickAddConfirmation(amount: String, category: String) -> String {
        t(it: "\(amount) · \(category) salvato in FinanzApp", en: "\(amount) · \(category) saved in FinanzApp", de: "\(amount) · \(category) in FinanzApp gespeichert", fr: "\(amount) · \(category) enregistré dans FinanzApp", es: "\(amount) · \(category) guardado en FinanzApp")
    }
}
