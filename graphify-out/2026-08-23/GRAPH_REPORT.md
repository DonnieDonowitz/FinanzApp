# Graph Report - FinanzApp  (2026-08-19)

## Corpus Check
- 152 files · ~107,520 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1554 nodes · 3194 edges · 113 communities (90 shown, 23 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 224 edges (avg confidence: 0.84)
- Token cost: 0 input · 535,907 output

## Community Hubs (Navigation)
- Shared Enums & Constants
- Widget & Database Core
- SQLite Database Manager
- Add Transaction View
- App Color Theme (Swift)
- Currency Formatting & Card UI
- Logo & Quick Add Bar
- Logo & Dialog (React Native)
- Android Adaptive Icon Config
- Bar Chart Rendering (Swift)
- Statistics View (Swift)
- Balance Card & Chart (RN)
- Navigation & Transaction Form (RN)
- Category Icon Styling (Swift)
- UI Icon Set (RN)
- Expo Dependencies
- Settings View (Swift)
- App Settings & Backup ViewModel
- Tax Profile ViewModel
- Recurring Transactions (RN)
- App State Context (RN)
- CSV Import Parsing
- Button Styles (Swift)
- Notification Manager (Swift)
- App Theme & Tinting (Swift)
- Glass UI Effect (Swift)
- Tax Engine Tests
- Transactions View (Swift)
- Recurring View (Swift)
- Tax Impact Calculation
- Category Picker (RN)
- Color Environment Injection (Swift)
- Core Tax Models (Swift)
- Database Backup & Fetch
- Date Formatting (Swift)
- Localization (Swift)
- Tax Set-Aside Card (Swift)
- Category Icon & Filter (RN)
- Settings & Backup (RN)
- App View Model (Swift)
- Threshold & Backup Settings
- App Root Entry (RN)
- Core Data Models (Swift)
- PartitaIVA App Root (Swift)
- Dashboard View Model (Tax)
- FinanzApp App Root (Swift)
- Tax Profile Model
- Currency Option Model
- Annual Summary View (Swift)
- Swipe to Delete Row (Swift)
- Invoice Model (Swift)
- Activity Details Step (Swift)
- Cassa Detail Section (Swift)
- Aliquota Sostitutiva Enum
- Transaction Row (Swift)
- Tax Computation Model
- Dashboard View (Swift)
- Add Invoice View (Swift)
- Tab Icons (RN)
- App Icon Assets
- Settings Row & Backup Cleanup
- INPS Contribution Calculator
- Category Form Sheet (Swift)
- Package Manifest (RN)
- Add Expense View (Swift)
- IRPEF Tax Calculator
- App Delegate (Swift)
- INPS Category Enum
- Invoices List View (Swift)
- Balance Bar Chart (RN)
- Recurring Scheduling Logic (Swift)
- Confirm Dialog (Swift)
- Tax Regime Model
- Tax Set-Aside Engine
- Share Sheet (Swift)
- Revenue Simulator View (Swift)
- Notification Delegate (Swift)
- Section Card (Swift)
- Recurring View State
- CSV Exporter (Swift)
- Settings View File Sharing
- Add Recurring View (Swift)
- Empty State Component (Swift)
- Xcode Project Targets
- npm Scripts (RN)
- Tax Rates Model
- Annual Summary State
- TypeScript Config
- Tab Bar Item (Swift)
- Expo v56 Docs Reference
- Metro Bundler Config
- Notification Message Text
- Expense List Deletion
- React Icon Factory
- PartitaIVA Test Target
- Favicon Brand Concept
- iOS IPA Build Script
- Expo Dev Client Dependency
- Expo Document Picker Dependency
- Expo File System Dependency
- Expo Linear Gradient Dependency
- FinanzApp iOS Icon Identity
- React DOM Dependency
- Chart Kit Dependency
- DateTimePicker Dependency
- React Native Web Dependency
- Bottom Tabs Navigation Dependency
- Native Stack Navigation Dependency
- PartitaIVA Branding Icon
- Android Icon Background Layer
- FinanzApp iOS App Icon
- FinanzApp Dark Icon Variant

## God Nodes (most connected - your core abstractions)
1. `L` - 138 edges
2. `AppViewModel` - 84 edges
3. `useTheme()` - 55 edges
4. `DatabaseManager` - 44 edges
5. `GlassView` - 41 edges
6. `TaxProfile` - 41 edges
7. `AppColors` - 34 edges
8. `TaxEngineTests` - 30 edges
9. `SettingsView` - 25 edges
10. `Expense` - 24 edges

## Surprising Connections (you probably didn't know these)
- `FinanzApp (iOS App Target)` --semantically_similar_to--> `PartitaIVA (iOS App Target, display name Solvo)`  [INFERRED] [semantically similar]
  Native_iOS/project.yml → PartitaIVA/project.yml
- `Invoice` --references--> `Date`  [EXTRACTED]
  PartitaIVA/PartitaIVA/Models/Invoice.swift → Native_iOS/FinanzApp/Models/Models.swift
- `AddExpenseView` --references--> `Date`  [EXTRACTED]
  PartitaIVA/PartitaIVA/Views/Expenses/AddExpenseView.swift → Native_iOS/FinanzApp/Models/Models.swift
- `AddInvoiceView` --references--> `Date`  [EXTRACTED]
  PartitaIVA/PartitaIVA/Views/Invoices/AddInvoiceView.swift → Native_iOS/FinanzApp/Models/Models.swift
- `.category` --references--> `AppViewModel`  [INFERRED]
  Native_iOS/FinanzApp/Views/StatisticsView.swift → Native_iOS/FinanzApp/ViewModels/AppViewModel.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **FinanzApp / FinanzAppWidget App Group Data Sharing** — native_ios_project_finanzapp, native_ios_project_finanzappwidget, native_ios_project_app_group [EXTRACTED 1.00]

## Communities (113 total, 23 thin omitted)

### Community 0 - "Shared Enums & Constants"
Cohesion: 0.03
Nodes (128): L, .active, .add, .addCategory, .addCustomThreshold, .all, .amount, .annualAnalysis (+120 more)

### Community 1 - "Widget & Database Core"
Cohesion: 0.06
Nodes (45): FinanzAppWidgetBundle, .body, QuickActionButton, .body, QuickActionsEntry, QuickActionsProvider, QuickActionsWidgetView, .body (+37 more)

### Community 2 - "SQLite Database Manager"
Cohesion: 0.12
Nodes (11): DatabaseManager, .dbPath, Any, Bool, Category, Int, Int64, RecurringTransaction (+3 more)

### Community 3 - "Add Transaction View"
Cohesion: 0.08
Nodes (30): AddTransactionView, .canSubmit, Bool, Category, Color, String, Transaction, Void (+22 more)

### Community 4 - "App Color Theme (Swift)"
Cohesion: 0.06
Nodes (33): AppColors, .accent, .balanceGradient, .balanceHighlight, .bg, .divider, .expense, .expenseLight (+25 more)

### Community 5 - "Currency Formatting & Card UI"
Cohesion: 0.09
Nodes (28): Color, Double, String, BreakdownRow, .body, Card, .body, CurrencyField (+20 more)

### Community 6 - "Logo & Quick Add Bar"
Cohesion: 0.08
Nodes (21): AppLogo, .body, QuickAddBar, .body, Void, ExpenseRow, .body, .dateLabel (+13 more)

### Community 7 - "Logo & Dialog (React Native)"
Cohesion: 0.11
Nodes (22): AppLogo(), LogoIcon(), LogoIconProps, styles, ConfirmDialog(), ConfirmDialogProps, styles, EmptyState() (+14 more)

### Community 8 - "Android Adaptive Icon Config"
Cohesion: 0.07
Nodes (28): backgroundColor, backgroundImage, foregroundImage, monochromeImage, adaptiveIcon, package, predictiveBackGestureEnabled, projectId (+20 more)

### Community 9 - "Bar Chart Rendering (Swift)"
Cohesion: 0.11
Nodes (23): Angle, BarData, CGRect, BarChartView, .body, .maxValue, BarData, ChartLegend (+15 more)

### Community 10 - "Statistics View (Swift)"
Cohesion: 0.14
Nodes (21): DateFormatter, BarData, CategoryBreakdownRow, .category, .color, RatioPoint, StatisticsView, .analysisTitle (+13 more)

### Community 11 - "Balance Card & Chart (RN)"
Cohesion: 0.15
Nodes (20): BalanceCard(), BalanceCardProps, styles, ChartView(), styles, TransactionItem(), useTransactions(), getGreeting() (+12 more)

### Community 12 - "Navigation & Transaction Form (RN)"
Cohesion: 0.10
Nodes (18): TransactionForm(), useCategories(), CustomTabBar(), HS, IS, RS, styles, Tab (+10 more)

### Community 13 - "Category Icon Styling (Swift)"
Cohesion: 0.14
Nodes (21): Font, .categoryName, BackgroundGradient, .body, CategoryIconView, resolvedIcon(), Category, CGFloat (+13 more)

### Community 14 - "UI Icon Set (RN)"
Cohesion: 0.08
Nodes (23): IconArrowDown, IconArrowLeft, IconArrowRight, IconArrowUp, IconCalendar, IconChart, IconChartPie, IconClose (+15 more)

### Community 15 - "Expo Dependencies"
Cohesion: 0.09
Nodes (23): expo, expo-blur, expo-sharing, expo-sqlite, expo-status-bar, dependencies, expo, expo-blur (+15 more)

### Community 16 - "Settings View (Swift)"
Cohesion: 0.12
Nodes (18): FileDocument, FileWrapper, FormField, .body, InfoRow, .body, .infoSection, Content (+10 more)

### Community 17 - "App Settings & Backup ViewModel"
Cohesion: 0.17
Nodes (10): AppViewModel, .autoBackupsDirectory, .categories, .monthBalance, .recentTransactions, .transactions, Bool, URL (+2 more)

### Community 18 - "Tax Profile ViewModel"
Cohesion: 0.13
Nodes (13): ObservableObject, ProfileStore, .profile, Bool, TaxProfileViewModel, .canProceedFromActivityDetails, .canProceedFromINPS, .canProceedFromLocation (+5 more)

### Community 19 - "Recurring Transactions (RN)"
Cohesion: 0.21
Nodes (16): RecurringItem(), RecurringItemProps, styles, RecurringTransaction, useRecurring(), AddRecurringScreen(), styles, RecurringScreen() (+8 more)

### Community 20 - "App State Context (RN)"
Cohesion: 0.17
Nodes (14): AppContext, AppContextType, AppProvider(), appReducer(), initialState, AppAction, AppSettings, AppState (+6 more)

### Community 21 - "CSV Import Parsing"
Cohesion: 0.14
Nodes (21): AMOUNT_PATTERNS, CATEGORY_COLORS, CATEGORY_PATTERNS, CreatedCategory, DATE_PATTERNS, DESC_PATTERNS, executeImport(), findColumn() (+13 more)

### Community 22 - "Button Styles (Swift)"
Cohesion: 0.12
Nodes (17): ButtonStyle, Configuration, Int, PrimaryButtonStyle, OnboardingContainerView, .body, .canProceed, OnboardingStep (+9 more)

### Community 23 - "Notification Manager (Swift)"
Cohesion: 0.17
Nodes (13): NotificationManager, Bool, Int, Void, SettingsView, .appearanceSection, .expenseAlertSection, .header (+5 more)

### Community 24 - "App Theme & Tinting (Swift)"
Cohesion: 0.17
Nodes (16): AppTinting, categoryIcon(), .body, Color, ColorScheme, .tinting, DarkTints, formatDate() (+8 more)

### Community 25 - "Glass UI Effect (Swift)"
Cohesion: 0.16
Nodes (15): GlassIntensity, regular, strong, GlassView, .bg, .body, .border, .highlight (+7 more)

### Community 26 - "Tax Engine Tests"
Cohesion: 0.24
Nodes (3): Double, TaxEngineTests, XCTestCase

### Community 27 - "Transactions View (Swift)"
Cohesion: 0.18
Nodes (14): getCurrentMonth(), FAB, .body, FilterChip, .body, Bool, Int, String (+6 more)

### Community 28 - "Recurring View (Swift)"
Cohesion: 0.14
Nodes (16): BrandToggle, .body, RecurringRow, .category, .categoryName, .color, .body, SummaryDivider (+8 more)

### Community 29 - "Tax Impact Calculation"
Cohesion: 0.18
Nodes (4): Double, Bool, Int, String

### Community 30 - "Category Picker (RN)"
Cohesion: 0.20
Nodes (13): CategoryPicker(), CategoryPickerProps, styles, FONT_FAMILY, styles, TransactionFormProps, TransactionItemProps, styles (+5 more)

### Community 31 - "Color Environment Injection (Swift)"
Cohesion: 0.14
Nodes (13): EnvironmentKey, AppColors, AppColorsKey, AppColorsProvider, AppPalette, EnvironmentValues, .appColors, Fmt (+5 more)

### Community 32 - "Core Tax Models (Swift)"
Cohesion: 0.13
Nodes (6): Foundation, ForfettarioEngine, OrdinarioEngine, ItalianRegions, String, SwiftData

### Community 34 - "Date Formatting (Swift)"
Cohesion: 0.15
Nodes (14): Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth, Expense, .category (+6 more)

### Community 35 - "Localization (Swift)"
Cohesion: 0.15
Nodes (15): AppLanguage, de, en, es, fr, .id, it, .localeIdentifier (+7 more)

### Community 36 - "Tax Set-Aside Card (Swift)"
Cohesion: 0.17
Nodes (12): AccantonamentoCard, .body, String, LocationStepView, .body, RegionPickerSheet, .body, String (+4 more)

### Community 37 - "Category Icon & Filter (RN)"
Cohesion: 0.16
Nodes (13): CategoryIcon(), Props, styles, FilterBar(), FilterBarProps, getMonthOptions(), styles, CATEGORY_ICONS (+5 more)

### Community 38 - "Settings & Backup (RN)"
Cohesion: 0.25
Nodes (12): SettingsScreen(), styles, buildBackupSQL(), createBackup(), esc(), escInt(), executeBackupRestore(), exportBackup() (+4 more)

### Community 39 - "App View Model (Swift)"
Cohesion: 0.25
Nodes (4): Combine, Double, TopCategory, String

### Community 40 - "Threshold & Backup Settings"
Cohesion: 0.17
Nodes (9): BackupFrequency, daily, .label, .minimumDays, monthly, weekly, Int, .addThresholdRow (+1 more)

### Community 41 - "App Root Entry (RN)"
Cohesion: 0.24
Nodes (9): App(), AppContent(), BackgroundGradient(), useAppContext(), AppNavigator(), DarkColors, getColors(), LightColors (+1 more)

### Community 42 - "Core Data Models (Swift)"
Cohesion: 0.24
Nodes (13): Codable, Category, .displayColor, .isIncome, RecurringTransaction, .isExpense, Bool, Color (+5 more)

### Community 43 - "PartitaIVA App Root (Swift)"
Cohesion: 0.15
Nodes (11): MainTabView, .body, PartitaIVAApp, .body, RootView, .body, Scene, ExpensesListView (+3 more)

### Community 44 - "Dashboard View Model (Tax)"
Cohesion: 0.16
Nodes (13): DashboardViewModel, .computation, .hasExceededForfettarioAbsoluteLimit, .isNearForfettarioLimit, .margineForfettario, .monthlyRecommendation, .ricaviTotali, .speseTotaliRegistrate (+5 more)

### Community 45 - "FinanzApp App Root (Swift)"
Cohesion: 0.18
Nodes (11): App, ContentView, .body, FinanzApp, .body, MainTabView, .body, Int (+3 more)

### Community 46 - "Tax Profile Model"
Cohesion: 0.18
Nodes (12): Equatable, Bool, Int, TaxProfile, .accantonatoAnnoCorrente, .anniAttivita, .atecoGroup, .coefficienteRedditivita (+4 more)

### Community 47 - "Currency Option Model"
Cohesion: 0.22
Nodes (12): Hashable, Identifiable, CurrencyOption, .id, .cassaRiduzioneSelezionata, .cassaSelezionata, CassaPrevidenziale, CassaRiduzione (+4 more)

### Community 48 - "Annual Summary View (Swift)"
Cohesion: 0.15
Nodes (12): .monthsShort, formatCurrency(), Double, AnnualSummaryView, .body, .months, .totalBalance, Double (+4 more)

### Community 49 - "Swipe to Delete Row (Swift)"
Cohesion: 0.22
Nodes (9): Bool, CGFloat, Content, String, Void, SwipeToDeleteRow, .body, .isArmed (+1 more)

### Community 50 - "Invoice Model (Swift)"
Cohesion: 0.22
Nodes (11): Invoice, .ritenutaAmount, .year, Bool, Double, Int, String, .recentInvoicesSection (+3 more)

### Community 51 - "Activity Details Step (Swift)"
Cohesion: 0.18
Nodes (10): SectionHeader, .body, ActivityDetailsStepView, .body, .forfettarioContent, .ordinarioContent, Binding, Double (+2 more)

### Community 52 - "Cassa Detail Section (Swift)"
Cohesion: 0.19
Nodes (10): CassaDetailSection, .aliquotaBinding, .body, .minimoBinding, Binding, Double, String, CassaPickerSheet (+2 more)

### Community 53 - "Aliquota Sostitutiva Enum"
Cohesion: 0.17
Nodes (12): CaseIterable, AliquotaSostitutiva, cinque, .id, .label, quindici, .rate, Double (+4 more)

### Community 54 - "Transaction Row (Swift)"
Cohesion: 0.18
Nodes (10): Category, Color, String, Transaction, TransactionRow, .category, .categoryColor, .categoryName (+2 more)

### Community 55 - "Tax Computation Model"
Cohesion: 0.17
Nodes (7): Double, Double, TaxComputation, .aliquotaEffettiva, .nettoDisponibile, .totaleDaAccantonare, TaxEngine

### Community 56 - "Dashboard View (Swift)"
Cohesion: 0.21
Nodes (11): DashboardView, .body, .currentYear, .dashboard, .expensesThisYear, .header, .invoicesThisYear, MargineForfettarioCard (+3 more)

### Community 57 - "Add Invoice View (Swift)"
Cohesion: 0.18
Nodes (10): AddInvoiceView, .body, .currentYear, .impattoMarginale, .ricaviEsistentiThisYear, .speseDeducibiliThisYear, Bool, Double (+2 more)

### Community 59 - "App Icon Assets"
Cohesion: 0.20
Nodes (10): app.json, Android Icon Foreground, Android Monochrome Icon, App Icon (FinanzApp), Splash Icon Image, Android Adaptive Icon, FinanzApp Chevron Brand Mark, Financial Growth Iconography (Bar Chart + Upward Arrow) (+2 more)

### Community 60 - "Settings Row & Backup Cleanup"
Cohesion: 0.20
Nodes (9): SectionLabel, .body, SettingsRow, .body, .autoBackupSection, .backupSection, .managementSection, .regionSection (+1 more)

### Community 61 - "INPS Contribution Calculator"
Cohesion: 0.42
Nodes (7): BreakdownLine, INPSCalculator, Result, Bool, Double, String, Int

### Community 62 - "Category Form Sheet (Swift)"
Cohesion: 0.29
Nodes (7): Category, CategoryFormSheet, .body, CategoryManagerView, .body, CategoryRow, Category

### Community 63 - "Package Manifest (RN)"
Cohesion: 0.20
Nodes (9): devDependencies, @types/react, typescript, main, name, private, version, @types/react (+1 more)

### Community 64 - "Add Expense View (Swift)"
Cohesion: 0.27
Nodes (8): ExpenseCategory, Double, String, AddExpenseView, .body, .selectedCategory, Double, String

### Community 65 - "IRPEF Tax Calculator"
Cohesion: 0.36
Nodes (4): IRPEFCalculator, Result, .totale, Double

### Community 66 - "App Delegate (Swift)"
Cohesion: 0.25
Nodes (7): AppDelegate, Any, Bool, NSObject, UIApplication, UIApplicationDelegate, UNUserNotificationCenterDelegate

### Community 67 - "INPS Category Enum"
Cohesion: 0.25
Nodes (8): INPSCategory, altraCassa, artigiani, commercianti, gestioneSeparata, .helpText, .id, .label

### Community 68 - "Invoices List View (Swift)"
Cohesion: 0.25
Nodes (6): InvoicesListView, .body, .emptyState, .totalThisYear, Double, IndexSet

### Community 69 - "Balance Bar Chart (RN)"
Cohesion: 0.36
Nodes (7): BalanceBarChart(), ChartViewProps, describeArc(), niceNum(), PieChartSvg(), polarToCartesian(), styles

### Community 70 - "Recurring Scheduling Logic (Swift)"
Cohesion: 0.38
Nodes (3): Scheduling, Bool, String

### Community 71 - "Confirm Dialog (Swift)"
Cohesion: 0.43
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 72 - "Tax Regime Model"
Cohesion: 0.29
Nodes (6): TaxRegime, forfettario, .id, .label, ordinario, .shortDescription

### Community 73 - "Tax Set-Aside Engine"
Cohesion: 0.38
Nodes (5): AccantonamentoEngine, MonthlyRecommendation, .progresso, Double, Int

### Community 74 - "Share Sheet (Swift)"
Cohesion: 0.38
Nodes (5): ShareSheet, Any, Context, UIActivityViewController, UIViewControllerRepresentable

### Community 75 - "Revenue Simulator View (Swift)"
Cohesion: 0.33
Nodes (6): SimulatorView, .computation, .maxRicaviSimulabili, .ricaviBinding, Binding, Double

### Community 76 - "Notification Delegate (Swift)"
Cohesion: 0.33
Nodes (5): Void, UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter

### Community 77 - "Section Card (Swift)"
Cohesion: 0.47
Nodes (4): SectionCard, .body, Content, String

### Community 78 - "Recurring View State"
Cohesion: 0.33
Nodes (6): RecurringView, .activeRecurring, .monthlyTotal, .nextDueDays, Double, Int

### Community 79 - "CSV Exporter (Swift)"
Cohesion: 0.40
Nodes (3): CSVExporter, String, URL

### Community 80 - "Settings View File Sharing"
Cohesion: 0.40
Nodes (5): SettingsView, ShareableFile, .id, String, URL

### Community 81 - "Add Recurring View (Swift)"
Cohesion: 0.40
Nodes (4): AddRecurringView, .canSubmit, Bool, Category

### Community 82 - "Empty State Component (Swift)"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "Xcode Project Targets"
Cohesion: 0.50
Nodes (5): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension), PartitaIVA (iOS App Target, display name Solvo), PartitaIVATests (Unit Test Bundle)

### Community 84 - "npm Scripts (RN)"
Cohesion: 0.40
Nodes (5): scripts, android, ios, start, web

### Community 85 - "Tax Rates Model"
Cohesion: 0.60
Nodes (4): Double, Int, TaxBracket, TaxRates

### Community 86 - "Annual Summary State"
Cohesion: 0.40
Nodes (5): AnnualSummaryView, .currentYear, .expensesThisYear, .invoicesThisYear, Int

### Community 87 - "TypeScript Config"
Cohesion: 0.40
Nodes (4): expo/tsconfig.base, compilerOptions, strict, extends

### Community 88 - "Tab Bar Item (Swift)"
Cohesion: 0.50
Nodes (4): .tabBar, String, TabItem, .body

### Community 89 - "Expo v56 Docs Reference"
Cohesion: 0.67
Nodes (3): Expo Framework (v56), Expo v56.0.0 Versioned Docs, CLAUDE.md AGENTS.md Include Directive

### Community 93 - "React Icon Factory"
Cohesion: 0.67
Nodes (3): react, react, makeIcon()

## Knowledge Gaps
- **372 isolated node(s):** `.body`, `.dbPath`, `.isIncome`, `.displayColor`, `.isExpense` (+367 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppViewModel` connect `App Settings & Backup ViewModel` to `Add Transaction View`, `Statistics View (Swift)`, `Category Icon Styling (Swift)`, `Tax Profile ViewModel`, `Notification Manager (Swift)`, `Glass UI Effect (Swift)`, `Transactions View (Swift)`, `Recurring View (Swift)`, `Database Backup & Fetch`, `Localization (Swift)`, `App View Model (Swift)`, `Threshold & Backup Settings`, `FinanzApp App Root (Swift)`, `Annual Summary View (Swift)`, `Transaction Row (Swift)`, `Settings Row & Backup Cleanup`, `Category Form Sheet (Swift)`, `Recurring View State`, `Add Recurring View (Swift)`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `L` connect `Shared Enums & Constants` to `Localization (Swift)`, `App View Model (Swift)`, `Statistics View (Swift)`, `Category Icon Styling (Swift)`, `Annual Summary View (Swift)`, `Notification Message Text`, `Expense List Deletion`, `Category Form Sheet (Swift)`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `TaxProfile` connect `Tax Profile Model` to `IRPEF Tax Calculator`, `INPS Category Enum`, `Tax Set-Aside Card (Swift)`, `Logo & Quick Add Bar`, `App View Model (Swift)`, `Tax Regime Model`, `Core Data Models (Swift)`, `Revenue Simulator View (Swift)`, `Dashboard View Model (Tax)`, `Currency Option Model`, `Tax Profile ViewModel`, `INPS Contribution Calculator`, `Activity Details Step (Swift)`, `Aliquota Sostitutiva Enum`, `Cassa Detail Section (Swift)`, `Tax Computation Model`, `Tax Engine Tests`, `Tax Impact Calculation`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **What connects `.body`, `.dbPath`, `.isIncome` to the rest of the system?**
  _372 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Shared Enums & Constants` be split into smaller, more focused modules?**
  _Cohesion score 0.03076550387596899 - nodes in this community are weakly interconnected._
- **Should `Widget & Database Core` be split into smaller, more focused modules?**
  _Cohesion score 0.06284153005464481 - nodes in this community are weakly interconnected._
- **Should `SQLite Database Manager` be split into smaller, more focused modules?**
  _Cohesion score 0.12173913043478261 - nodes in this community are weakly interconnected._