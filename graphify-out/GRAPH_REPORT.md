# Graph Report - FinanzApp  (2026-08-23)

## Corpus Check
- 38 files · ~39,226 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 843 nodes · 1824 edges · 39 communities (32 shown, 7 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 170 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5e85c42b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- L
- Widgets.swift
- DatabaseManager
- HomeView
- AppColors
- CategoryEntity
- LevelUpOverlay
- BalanceCard
- StatisticsView
- GapDonutChart
- LinearGradient
- View
- Gamification
- Theme.swift
- NotificationManager
- .body
- SettingsView
- AppViewModel
- Int
- ConfirmDialog
- TextFileDocument
- GlassView
- SwipeToDeleteRow
- RecurringRow
- .budgetCard
- AGENTS.md
- AppLanguage
- FinanzApp.swift
- AppDelegate
- SwiftUI
- EmptyState
- App Group group.com.finanzapp.app
- CLAUDE.md AGENTS.md Include Directive
- String
- build-ipa.sh
- FinanzApp iOS App Identity
- FinanzApp iOS App Icon
- FinanzApp Dark App Icon

## God Nodes (most connected - your core abstractions)
1. `L` - 162 edges
2. `AppViewModel` - 96 edges
3. `AppColors` - 51 edges
4. `GlassView` - 48 edges
5. `DatabaseManager` - 44 edges
6. `StatisticsView` - 35 edges
7. `Transaction` - 34 edges
8. `SettingsView` - 27 edges
9. `Category` - 26 edges
10. `HomeView` - 19 edges

## Surprising Connections (you probably didn't know these)
- `.recentTransactions` --references--> `Transaction`  [INFERRED]
  Native_iOS/FinanzApp/ViewModels/AppViewModel.swift → Native_iOS/FinanzApp/Models/Models.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/BalanceCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/EmptyState.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `GlassView`  [INFERRED]
  Native_iOS/FinanzApp/Views/Components/SectionCard.swift → Native_iOS/FinanzApp/Views/Components/GlassView.swift
- `.body` --calls--> `BackgroundGradient`  [INFERRED]
  Native_iOS/FinanzApp/App/FinanzApp.swift → Native_iOS/FinanzApp/Theme/Theme.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **FinanzApp / FinanzAppWidget App Group Data Sharing** — native_ios_project_finanzapp, native_ios_project_finanzappwidget, native_ios_project_app_group [EXTRACTED 1.00]

## Communities (39 total, 7 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (143): L, .active, .add, .addCategory, .addCustomThreshold, .advancedStatistics, .all, .amount (+135 more)

### Community 1 - "Widgets.swift"
Cohesion: 0.05
Nodes (55): Context, Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth, FinanzAppWidgetBundle (+47 more)

### Community 2 - "DatabaseManager"
Cohesion: 0.07
Nodes (23): Codable, Identifiable, DatabaseManager, .dbPath, Any, Bool, Int, Int64 (+15 more)

### Community 3 - "HomeView"
Cohesion: 0.12
Nodes (18): AddTransactionView, .canSubmit, Bool, Color, String, Void, TypeChip, .body (+10 more)

### Community 4 - "AppColors"
Cohesion: 0.06
Nodes (34): AppColors, .accent, .balanceGradient, .balanceHighlight, .bg, .divider, .expense, .expenseLight (+26 more)

### Community 5 - "CategoryEntity"
Cohesion: 0.10
Nodes (23): AppEntity, AppIntent, AppIntents, AppShortcut, AppShortcutsProvider, DisplayRepresentation, EntityQuery, IntentResult (+15 more)

### Community 6 - "LevelUpOverlay"
Cohesion: 0.50
Nodes (3): LevelUpOverlay, Int, Void

### Community 7 - "BalanceCard"
Cohesion: 0.24
Nodes (10): BalanceCard, .amountDec, .amountInt, .body, FlowChip, .body, .flowAmount, Color (+2 more)

### Community 8 - "StatisticsView"
Cohesion: 0.15
Nodes (15): DateFormatter, StatisticsView, .body, .currentHalf, .currentYear, .header, .monthStepper, .periodSelector (+7 more)

### Community 9 - "GapDonutChart"
Cohesion: 0.14
Nodes (20): CGPoint, ChartLegend, .body, DailyBarChart, .barSpacing, .body, .maxValue, GapDonutChart (+12 more)

### Community 10 - "LinearGradient"
Cohesion: 0.18
Nodes (10): LinearGradient, .tabBar, Any, Bool, String, TabItem, .body, .body (+2 more)

### Community 11 - "View"
Cohesion: 0.14
Nodes (22): AppLogo, .body, View, CategoryFormSheet, CategoryManagerView, .body, CategoryRow, FormField (+14 more)

### Community 12 - "Gamification"
Cohesion: 0.16
Nodes (9): Foundation, Gamification, LevelInfo, Double, Int, Scheduling, Bool, String (+1 more)

### Community 13 - "Theme.swift"
Cohesion: 0.08
Nodes (34): Font, AppTinting, categoryIcon(), CategoryIconView, .body, Color, ColorScheme, .tinting (+26 more)

### Community 14 - "NotificationManager"
Cohesion: 0.16
Nodes (7): Notification.Name, NotificationManager, Bool, Int, Void, UNAuthorizationStatus, UserNotifications

### Community 15 - ".body"
Cohesion: 0.16
Nodes (11): .categoryName, BackgroundGradient, .body, .body, .body, CategoryPicker, .body, .filteredCategories (+3 more)

### Community 16 - "SettingsView"
Cohesion: 0.18
Nodes (13): ImporterKind, autoBackupFolder, restoreBackup, SettingsView, .appearanceSection, .autoBackupSection, .body, .expenseAlertSection (+5 more)

### Community 17 - "AppViewModel"
Cohesion: 0.09
Nodes (18): AppViewModel, .autoBackupsDirectory, .categories, .currentLevel, .isBudgetConfigured, .isOverBudget, .levelProgress, .monthBalance (+10 more)

### Community 18 - "Int"
Cohesion: 0.27
Nodes (4): Bool, Int, .addThresholdRow, Int

### Community 19 - "ConfirmDialog"
Cohesion: 0.43
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 22 - "TextFileDocument"
Cohesion: 0.17
Nodes (10): FileDocument, FileWrapper, .backupSection, TextFileDocument, .readableContentTypes, .writableContentTypes, UTType, .finanzBackup (+2 more)

### Community 25 - "GlassView"
Cohesion: 0.17
Nodes (13): GlassIntensity, regular, strong, GlassView, .bg, .border, .highlight, .insetOpacity (+5 more)

### Community 27 - "SwipeToDeleteRow"
Cohesion: 0.09
Nodes (25): .monthsShort, getCurrentMonth(), Bool, CGFloat, Content, String, Void, SwipeToDeleteRow (+17 more)

### Community 28 - "RecurringRow"
Cohesion: 0.09
Nodes (23): AddRecurringView, .canSubmit, Bool, BrandToggle, .body, RecurringRow, .category, .categoryName (+15 more)

### Community 35 - "AppLanguage"
Cohesion: 0.06
Nodes (32): CaseIterable, Combine, Hashable, AppLanguage, de, en, es, fr (+24 more)

### Community 45 - "FinanzApp.swift"
Cohesion: 0.24
Nodes (9): App, ContentView, .body, FinanzApp, .body, MainTabView, .body, Int (+1 more)

### Community 76 - "AppDelegate"
Cohesion: 0.20
Nodes (9): AppDelegate, Void, NSObject, UIApplicationDelegate, UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter (+1 more)

### Community 77 - "SwiftUI"
Cohesion: 0.14
Nodes (11): BudgetEditSheet, .parsedAmount, Double, QuickAddBar, .body, Void, SectionCard, .body (+3 more)

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

### Community 91 - "String"
Cohesion: 0.14
Nodes (7): Int, Double, .dailyChartCard, .levelCard, .summaryCard, Color, String

## Knowledge Gaps
- **146 isolated node(s):** `.dbPath`, `AppIntents`, `.parameterSummary`, `.isIncome`, `.displayColor` (+141 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppViewModel` connect `AppViewModel` to `DatabaseManager`, `AppLanguage`, `HomeView`, `StatisticsView`, `SwipeToDeleteRow`, `View`, `Gamification`, `FinanzApp.swift`, `Theme.swift`, `.body`, `NotificationManager`, `SettingsView`, `Int`, `SwiftUI`, `GlassView`, `String`, `RecurringRow`?**
  _High betweenness centrality (0.241) - this node is a cross-community bridge._
- **Why does `L` connect `L` to `AppLanguage`, `CategoryEntity`, `String`, `View`, `.body`, `SwipeToDeleteRow`, `.budgetCard`?**
  _High betweenness centrality (0.227) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `Widgets.swift`, `HomeView`, `LevelUpOverlay`, `BalanceCard`, `StatisticsView`, `GapDonutChart`, `LinearGradient`, `Theme.swift`, `.body`, `SettingsView`, `Int`, `ConfirmDialog`, `GlassView`, `SwipeToDeleteRow`, `RecurringRow`, `FinanzApp.swift`, `SwiftUI`, `EmptyState`, `String`?**
  _High betweenness centrality (0.218) - this node is a cross-community bridge._
- **What connects `.dbPath`, `AppIntents`, `.parameterSummary` to the rest of the system?**
  _146 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.027583527583527584 - nodes in this community are weakly interconnected._
- **Should `Widgets.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.050078247261345854 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.07472613458528951 - nodes in this community are weakly interconnected._