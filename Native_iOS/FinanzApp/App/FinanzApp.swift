import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == NotificationManager.reminderIdentifier {
            NotificationCenter.default.post(name: .openQuickAddExpense, object: nil)
        }
        completionHandler()
    }
}

@main
struct FinanzApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .preferredColorScheme(vm.isDarkMode ? .dark : .light)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            BackgroundGradient()
            if vm.isLoading {
                ProgressView().tint(AppColors.text)
            } else {
                MainTabView(selectedTab: $selectedTab).environmentObject(vm)
            }

            if let level = vm.justLeveledUpTo {
                LevelUpOverlay(level: level) { vm.justLeveledUpTo = nil }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openQuickAddExpense)) { _ in
            selectedTab = 0
            vm.pendingQuickAddType = "expense"
        }
        .onOpenURL { url in
            guard url.scheme == "finanzapp", url.host == "add" else { return }
            let type = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "type" })?.value
            selectedTab = 0
            vm.pendingQuickAddType = type == "income" ? "income" : "expense"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var vm: AppViewModel
    @Binding var selectedTab: Int
    @State private var showTransactions = false
    @Namespace private var tabIndicator

    var body: some View {
        ZStack(alignment: .bottom) {
            // All four tabs are kept mounted (instead of switching which one exists), so
            // switching tabs is just an opacity toggle rather than tearing down and rebuilding
            // an entire glass-heavy view hierarchy. `selectedTab` lives here as a plain
            // @State/@Binding rather than on `vm` (an ObservableObject shared by all four
            // screens) — if it lived on `vm`, every tab switch would publish a change that
            // invalidates and re-renders all four already-mounted screens at once, which is
            // more work than the reconstruction this was meant to avoid.
            ZStack {
                HomeView(showTransactions: $showTransactions)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .scaleEffect(selectedTab == 0 ? 1 : 0.97)
                    .allowsHitTesting(selectedTab == 0)
                    .accessibilityHidden(selectedTab != 0)
                StatisticsView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .scaleEffect(selectedTab == 1 ? 1 : 0.97)
                    .allowsHitTesting(selectedTab == 1)
                    .accessibilityHidden(selectedTab != 1)
                TransactionsView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .scaleEffect(selectedTab == 2 ? 1 : 0.97)
                    .allowsHitTesting(selectedTab == 2)
                    .accessibilityHidden(selectedTab != 2)
                RecurringView()
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .scaleEffect(selectedTab == 3 ? 1 : 0.97)
                    .allowsHitTesting(selectedTab == 3)
                    .accessibilityHidden(selectedTab != 3)
                SettingsView()
                    .opacity(selectedTab == 4 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 4)
                    .accessibilityHidden(selectedTab != 4)
            }
            .environmentObject(vm)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .sheet(isPresented: $showTransactions) {
            TransactionsView().environmentObject(vm)
        }
    }

    /// Wrapping the change in `withAnimation` is enough on its own — every dependent property
    /// above (`opacity`/`scaleEffect` per screen, the tab bar's `matchedGeometryEffect` pill)
    /// animates as one coordinated transaction without needing a separate `.animation(value:)`.
    private func select(_ tab: Int) {
        guard tab != selectedTab else { return }
        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
            selectedTab = tab
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            TabItem(icon: "house.fill", label: L.tabHome, isActive: selectedTab == 0, isDark: vm.isDarkMode, namespace: tabIndicator)
                .onTapGesture { select(0) }
            TabItem(icon: "chart.bar.fill", label: L.tabStatistics, isActive: selectedTab == 1, isDark: vm.isDarkMode, namespace: tabIndicator)
                .onTapGesture { select(1) }
            TabItem(icon: "list.bullet", label: L.tabMovements, isActive: selectedTab == 2, isDark: vm.isDarkMode, namespace: tabIndicator)
                .onTapGesture { select(2) }
            TabItem(icon: "arrow.triangle.2.circlepath", label: L.tabRecurring, isActive: selectedTab == 3, isDark: vm.isDarkMode, namespace: tabIndicator)
                .onTapGesture { select(3) }
            TabItem(icon: "gearshape.fill", label: L.tabSettings, isActive: selectedTab == 4, isDark: vm.isDarkMode, namespace: tabIndicator)
                .onTapGesture { select(4) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.tabBar)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.tabBarBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow, radius: 14, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let isDark: Bool
    var namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isActive {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.primary.opacity(isDark ? 0.30 : 0.18))
                        .matchedGeometryEffect(id: "activeTabPill", in: namespace)
                        .frame(width: 38, height: 30)
                }
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(isActive ? AppColors.tabActive : AppColors.tabInactive)
            }
            .frame(height: 30)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isActive ? AppColors.tabActive : AppColors.tabInactive)
                .tracking(0.1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}