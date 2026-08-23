# Graph Report - FinanzApp  (2026-08-23)

## Corpus Check
- 38 files · ~39,520 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 844 nodes · 1826 edges · 48 communities (39 shown, 9 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 170 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `88e92769`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- L
- .getTimeline
- DatabaseManager
- HomeView
- AppColors
- CategoryEntity
- Widgets.swift
- BalanceCard
- QuickActionsEntry
- View
- TabItem
- SectionLabel
- Gamification
- Theme.swift
- .addTransaction
- SettingsView.swift
- SettingsView
- AppViewModel
- Int
- ConfirmDialog
- StatsWidgetView
- AddTransactionView
- TextFileDocument
- BackupFrequency
- MainTabView
- GlassView
- Date
- SwipeToDeleteRow
- RecurringRow
- StatsEntry
- .budgetCard
- AGENTS.md
- SectionCard
- BudgetEditSheet
- .regionSection
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
- `.body` --calls--> `HomeView`  [INFERRED]
  Native_iOS/FinanzApp/App/FinanzApp.swift → Native_iOS/FinanzApp/Views/HomeView.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **FinanzApp / FinanzAppWidget App Group Data Sharing** — native_ios_project_finanzapp, native_ios_project_finanzappwidget, native_ios_project_app_group [EXTRACTED 1.00]

## Communities (48 total, 9 thin omitted)

### Community 0 - "L"
Cohesion: 0.03
Nodes (143): L, .active, .add, .addCategory, .addCustomThreshold, .advancedStatistics, .all, .amount (+135 more)

### Community 1 - ".getTimeline"
Cohesion: 0.19
Nodes (10): .mediumBody, .smallBody, Color, Double, Int, String, widgetCurrency(), WidgetData (+2 more)

### Community 2 - "DatabaseManager"
Cohesion: 0.08
Nodes (23): Codable, Identifiable, DatabaseManager, .dbPath, Any, Bool, Int, Int64 (+15 more)

### Community 3 - "HomeView"
Cohesion: 0.21
Nodes (10): HomeView, .body, .header, SectionHeader, .body, Binding, Bool, Int (+2 more)

### Community 4 - "AppColors"
Cohesion: 0.06
Nodes (34): AppColors, .accent, .balanceGradient, .balanceHighlight, .bg, .divider, .expense, .expenseLight (+26 more)

### Community 5 - "CategoryEntity"
Cohesion: 0.09
Nodes (24): AppEntity, AppIntent, AppIntents, AppShortcut, AppShortcutsProvider, DisplayRepresentation, EntityQuery, IntentResult (+16 more)

### Community 6 - "Widgets.swift"
Cohesion: 0.23
Nodes (13): FinanzAppWidgetBundle, .body, QuickActionsWidgetView, .t, QuickAddWidget, .body, StatsWidget, .body (+5 more)

### Community 7 - "BalanceCard"
Cohesion: 0.24
Nodes (10): BalanceCard, .amountDec, .amountInt, .body, FlowChip, .body, .flowAmount, Color (+2 more)

### Community 8 - "QuickActionsEntry"
Cohesion: 0.27
Nodes (8): Context, QuickActionsEntry, QuickActionsProvider, StatsProvider, Void, Timeline, TimelineEntry, TimelineProvider

### Community 9 - "View"
Cohesion: 0.07
Nodes (38): CGPoint, DateFormatter, ChartLegend, .body, DailyBarChart, .barSpacing, .body, .maxValue (+30 more)

### Community 10 - "TabItem"
Cohesion: 0.29
Nodes (6): Any, Bool, String, TabItem, .body, UIApplication

### Community 11 - "SectionLabel"
Cohesion: 0.21
Nodes (12): FormField, .body, InfoRow, .body, SectionLabel, .body, SettingsRow, .budgetSection (+4 more)

### Community 12 - "Gamification"
Cohesion: 0.36
Nodes (5): Gamification, LevelInfo, Double, Int, .monthlyBudget

### Community 13 - "Theme.swift"
Cohesion: 0.05
Nodes (51): Font, .body, .categoryName, AppTinting, BackgroundGradient, categoryIcon(), CategoryIconView, .body (+43 more)

### Community 15 - "SettingsView.swift"
Cohesion: 0.18
Nodes (12): CategoryFormSheet, CategoryManagerView, .body, CategoryRow, .body, ImporterKind, autoBackupFolder, restoreBackup (+4 more)

### Community 16 - "SettingsView"
Cohesion: 0.19
Nodes (13): NotificationManager, Bool, Void, SettingsView, .appearanceSection, .autoBackupSection, .expenseAlertSection, .header (+5 more)

### Community 17 - "AppViewModel"
Cohesion: 0.11
Nodes (15): AppViewModel, .autoBackupsDirectory, .categories, .currentLevel, .isBudgetConfigured, .isOverBudget, .levelProgress, .monthBalance (+7 more)

### Community 18 - "Int"
Cohesion: 0.39
Nodes (3): Int, .addThresholdRow, Int

### Community 19 - "ConfirmDialog"
Cohesion: 0.53
Nodes (5): ConfirmDialog, .body, Bool, String, Void

### Community 20 - "StatsWidgetView"
Cohesion: 0.18
Nodes (12): QuickActionButton, .body, .body, StatsWidgetView, .body, .monthName, .progressBar, .statusColor (+4 more)

### Community 21 - "AddTransactionView"
Cohesion: 0.31
Nodes (8): AddTransactionView, .canSubmit, Bool, Color, String, Void, TypeChip, .body

### Community 22 - "TextFileDocument"
Cohesion: 0.17
Nodes (10): FileDocument, FileWrapper, .backupSection, TextFileDocument, .readableContentTypes, .writableContentTypes, UTType, .finanzBackup (+2 more)

### Community 23 - "BackupFrequency"
Cohesion: 0.20
Nodes (8): Combine, BackupFrequency, daily, .label, .minimumDays, monthly, weekly, TopCategory

### Community 24 - "MainTabView"
Cohesion: 0.29
Nodes (7): LinearGradient, MainTabView, .body, .tabBar, Int, .body, .body

### Community 25 - "GlassView"
Cohesion: 0.17
Nodes (13): GlassIntensity, regular, strong, GlassView, .bg, .border, .highlight, .insetOpacity (+5 more)

### Community 26 - "Date"
Cohesion: 0.29
Nodes (6): Date, .currentMonth, .currentString, .fullIT, .shortIT, .yearMonth

### Community 27 - "SwipeToDeleteRow"
Cohesion: 0.10
Nodes (25): .monthsShort, getCurrentMonth(), Bool, CGFloat, Content, String, Void, SwipeToDeleteRow (+17 more)

### Community 28 - "RecurringRow"
Cohesion: 0.11
Nodes (19): BrandToggle, .body, RecurringRow, .categoryName, .color, RecurringView, .activeRecurring, .body (+11 more)

### Community 29 - "StatsEntry"
Cohesion: 0.29
Nodes (7): StatsEntry, .isOverBudget, .progress, .remaining, Bool, Double, Int

### Community 32 - "SectionCard"
Cohesion: 0.60
Nodes (4): SectionCard, .body, Content, String

### Community 33 - "BudgetEditSheet"
Cohesion: 0.50
Nodes (3): BudgetEditSheet, .parsedAmount, Double

### Community 35 - "AppLanguage"
Cohesion: 0.06
Nodes (30): CaseIterable, Foundation, Hashable, Scheduling, Bool, String, Notification.Name, AppLanguage (+22 more)

### Community 45 - "FinanzApp.swift"
Cohesion: 0.40
Nodes (5): App, ContentView, FinanzApp, .body, Scene

### Community 76 - "AppDelegate"
Cohesion: 0.20
Nodes (9): AppDelegate, Void, NSObject, UIApplicationDelegate, UNNotification, UNNotificationPresentationOptions, UNNotificationResponse, UNUserNotificationCenter (+1 more)

### Community 77 - "SwiftUI"
Cohesion: 0.18
Nodes (6): AppLogo, .body, QuickAddBar, .body, Void, SwiftUI

### Community 82 - "EmptyState"
Cohesion: 0.50
Nodes (3): EmptyState, .body, String

### Community 83 - "App Group group.com.finanzapp.app"
Cohesion: 1.00
Nodes (3): App Group group.com.finanzapp.app, FinanzApp (iOS App Target), FinanzAppWidget (WidgetKit App Extension)

### Community 91 - "String"
Cohesion: 0.16
Nodes (7): Int, Double, .dailyChartCard, .levelCard, .summaryCard, Color, String

## Knowledge Gaps
- **146 isolated node(s):** `.dbPath`, `AppIntents`, `.parameterSummary`, `.isIncome`, `.displayColor` (+141 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppViewModel` connect `AppViewModel` to `DatabaseManager`, `HomeView`, `View`, `Gamification`, `Theme.swift`, `.addTransaction`, `SettingsView.swift`, `SettingsView`, `Int`, `AddTransactionView`, `BackupFrequency`, `MainTabView`, `GlassView`, `SwipeToDeleteRow`, `RecurringRow`, `BudgetEditSheet`, `.regionSection`, `AppLanguage`, `FinanzApp.swift`, `String`?**
  _High betweenness centrality (0.240) - this node is a cross-community bridge._
- **Why does `L` connect `L` to `AppLanguage`, `CategoryEntity`, `String`, `Theme.swift`, `.addTransaction`, `SettingsView.swift`, `SwipeToDeleteRow`, `.budgetCard`?**
  _High betweenness centrality (0.226) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `HomeView`, `Widgets.swift`, `BalanceCard`, `TabItem`, `SectionLabel`, `Theme.swift`, `SettingsView.swift`, `SettingsView`, `Int`, `ConfirmDialog`, `StatsWidgetView`, `AddTransactionView`, `MainTabView`, `GlassView`, `SwipeToDeleteRow`, `RecurringRow`, `SectionCard`, `BudgetEditSheet`, `FinanzApp.swift`, `SwiftUI`, `EmptyState`, `String`?**
  _High betweenness centrality (0.219) - this node is a cross-community bridge._
- **What connects `.dbPath`, `AppIntents`, `.parameterSummary` to the rest of the system?**
  _146 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `L` be split into smaller, more focused modules?**
  _Cohesion score 0.027583527583527584 - nodes in this community are weakly interconnected._
- **Should `DatabaseManager` be split into smaller, more focused modules?**
  _Cohesion score 0.07605633802816901 - nodes in this community are weakly interconnected._
- **Should `AppColors` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._